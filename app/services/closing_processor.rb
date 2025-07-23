class ClosingProcessor
  def initialize(closing)
    @closing = closing
    @start_date = Date.parse(@closing.start_date.strftime("%Y-%m-%d"))
    @end_date = Date.parse(@closing.end_date.strftime("%Y-%m-%d"))
    @periodo_para_desacumular = 10
    @valor_de_vendas_para_desacumular = 667.0
    @minimo_de_de_vendas_para_desacumular = 1
  end

  def call
    broadcast("Iniciando fechamento...")
    # execute_script

    # Importers::GroupDuplicates.new("#{Rails.root}/tmp/all.csv").import!

    # ["fc01000", "fc08000"].each do |file|
    #   ImportCsvService.new("#{Rails.root}/tmp/#{file}.csv").import!
    #   sleep 3
    # end

    broadcast("Gerando requisições dos prescritores...")
    ImportCsvService.new("#{Rails.root}/tmp/group_duplicates.csv").import!

    broadcast("Gerando relatórios mensais...")
    create_monthly_reports
    # cleanup_temp_files

    broadcast("Fechamento concluído com sucesso.")
  rescue => e
    broadcast("Erro no fechamento: #{e.message}")
  end

  def execute_script
    success = system("#{Rails.root}/script/converter.sh #{@start_date} #{@end_date}")

    raise "Erro ao executar script" unless success
  end

  def broadcast(message)
    ClosingChannel.broadcast_to("closing_#{@closing.id}", {message: message})
  end

  def create_monthly_reports
    Request.where("value_for_report < amount_received")
      .where("value_for_report >= ?", 25.0)
      .where.not(payment_date: nil)
      .update_all("amount_received = value_for_report")

    requests = Request.where(entry_date: @start_date..@end_date).group_by(&:prescriber_id)

    requests.each_with_index do |(prescriber_id, requests_all), index|
      prescriber = Prescriber.find(prescriber_id)
      representative = requests_all.last.representative
      total_price = requests_all.sum(&:total_price)
      quantity = requests_all.count

      accumulated = if quantity >= @minimo_de_de_vendas_para_desacumular && total_price >= @valor_de_vendas_para_desacumular
        0
      else
        1
      end

      monthly_report = MonthlyReport.create!(
        accumulated: accumulated,
        closing_id: @closing.id,
        prescriber: prescriber,
        representative: representative
      )

      requests_all.map { |r| r.update(monthly_report_id: monthly_report.id, closing_id: @closing.id) }
    end

    calculate_commission_on_sales

    # monthly_reports = MonthlyReport.includes(:prescriber)
    #   .where(closing_id: @closing.id).where.not(representative_id: nil)

    # monthly_reports.each do |monthly_report|
    #   prescriber = monthly_report.prescriber
    #   discount_percentage = prescriber.consider_discount_of_up_to.to_f / 100.0

    #   suitable_requisitions = Request.where(prescriber_id: prescriber.id, repeat: false)
    #     .where(payment_date: @start_date..@end_date, entry_date: @start_date..@end_date)
    #     .where("requests.total_discounts <= requests.total_price * ?", discount_percentage)
    #     .left_joins(:monthly_report)
    #     .where("monthly_reports.accumulated = ? OR requests.monthly_report_id IS NULL", true)

    #   suitable_requisitions.update_all(monthly_report_id: monthly_report.id)
    # end

    envelope_number = MonthlyReport.where(accumulated: false).maximum(:envelope_number).to_i

    Request.where(entry_date: @start_date..@end_date)
      .where.not(monthly_report_id: nil).includes(:monthly_report).each do |request|
      next if request.monthly_report.accumulated

      envelope_number += 1
      request.monthly_report.update(envelope_number: envelope_number)
    end

    monthly_reports = MonthlyReport.joins(:prescriber).where(closing_id: @closing.id)

    monthly_reports.each do |monthly_report|
      requests = monthly_report.requests
      prescriber = monthly_report.prescriber
      standard_account = prescriber.current_accounts.find_by(standard: true)
      total = ((prescriber.partnership.to_f / 100.0) * requests.sum(&:amount_received)).round(2)
      partnership = standard_account ? total : total.round(-1)
      discounts = requests.sum(&:total_discounts) * ([prescriber.discount_of_up_to, 1].max / 100.0)

      monthly_report.update!(
        quantity: requests.count,
        total_price: requests.sum(&:total_price),
        partnership: partnership,
        discounts: discounts
      )
    end

    monthly_reports.where("prescribers.repetitions > 0").each do |monthly_report|
      prescriber = monthly_report.prescriber
      repetitions = prescriber.repetitions.to_f / 100.0
      discount_percentage = prescriber.consider_discount_of_up_to.to_f / 100.0

      available_requests = prescriber.requests.where(repeat: true)
        .where(entry_date: @start_date..@end_date)
        .where(payment_date: @start_date..@end_date)
        .where("total_discounts <= total_price * ?", discount_percentage)
        .order(:total_price)

      limite = (available_requests.count * repetitions).to_i

      if limite > 0
        accepted_requests = available_requests.limit(limite)
        not_accepted_requests = available_requests.where.not(id: accepted_requests.ids)
        standard_account = prescriber.current_accounts.find_by(standard: true)
        total = ((prescriber.partnership.to_f / 100.0) * not_accepted_requests.sum(&:amount_received)).round(2)
        partnership = standard_account ? total : total.round(-1)

        attributes = {
          total_price: monthly_report.total_price.to_f - not_accepted_requests.sum(&:total_price).to_f,
          quantity: monthly_report.quantity - not_accepted_requests.count,
          discounts: [monthly_report.discounts.to_f - not_accepted_requests.sum(&:total_discounts).to_f, 0].max,
          partnership: [monthly_report.partnership.to_f - partnership.to_f, 0].max
        }

        monthly_report.update!(attributes)
        not_accepted_requests.destroy_all
      end

      if limite <= 0
        standard_account = prescriber.current_accounts.find_by(standard: true)
        total = ((prescriber.partnership.to_f / 100.0) * available_requests.sum(&:amount_received)).round(2)
        partnership = standard_account ? total : total.round(-1)

        attributes = {
          total_price: monthly_report.total_price.to_f - available_requests.sum(&:total_price).to_f,
          quantity: monthly_report.quantity - available_requests.count,
          discounts: monthly_report.discounts.to_f - available_requests.sum(&:total_discounts).to_f,
          partnership: monthly_report.partnership.to_f - partnership.to_f
        }

        monthly_report.update!(attributes)
        available_requests.destroy_all
      end
    end
  end

  def calculate_commission_on_sales
    monthly_reports = MonthlyReport
      .joins("LEFT JOIN representatives ON representatives.id = monthly_reports.representative_id")
      .joins("LEFT JOIN current_accounts ON current_accounts.representative_id = representatives.id AND current_accounts.standard = true")
      .where(closing_id: @closing.id, accumulated: false)
      .where("representatives.branch_id IS NULL")
      .where.not("current_accounts.id" => nil)
      .group("monthly_reports.representative_id, representatives.partnership")
      .pluck(
        "monthly_reports.representative_id",
        "SUM(monthly_reports.total_price)",
        "SUM(monthly_reports.quantity)",
        "representatives.partnership"
      )

    if monthly_reports.present?
      monthly_reports.each do |representative_id, sum_total_price, sum_quantity, partnership|
        comission = sum_total_price.to_f * (partnership.to_f / 100)

        monthly_report = MonthlyReport.find_by(
          closing_id: @closing.id,
          representative_id: representative_id
        )

        if monthly_report.present?
          monthly_report.update!(
            valor_total: sum_total_price,
            partnership: comission,
            quantity: sum_quantity,
            accumulated: false
          )
        end
      end
    end
  end

  def cleanup_temp_files
    %w[fc all group_duplicates].each do |prefix|
      Dir.glob(Rails.root.join("tmp", "#{prefix}*.csv")).each { |file| File.delete(file) }
    end
  end
end
