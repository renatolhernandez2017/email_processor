class ClosingProcessor
  def initialize(closing)
    @closing = closing
    @start_date = @closing.start_date.strftime("%Y-%m-%d")
    @end_date = @closing.end_date.strftime("%Y-%m-%d")
    @periodo_para_desacumular = 10
    @valor_de_vendas_para_desacumular = 667.0
    @minimo_de_de_vendas_para_desacumular = 1
  end

  def call
    broadcast("Iniciando fechamento...")
    execute_script

    Importers::GroupDuplicates.new("#{Rails.root}/tmp/all.csv").import!

    ["fc01000", "fc08000"].each do |file|
      ImportCsvService.new("#{Rails.root}/tmp/#{file}.csv").import!
      sleep 3
    end

    broadcast("Gerando requisições dos prescritores...")
    ImportCsvService.new("#{Rails.root}/tmp/group_duplicates.csv").import!

    broadcast("Gerando relatórios mensais...")
    create_monthly_reports
    cleanup_temp_files

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
      discount_of_up_to = [prescriber.discount_of_up_to, 1].max
      discounts = requests_all.sum(&:total_discounts) * (discount_of_up_to / 100.0)
      amount_received = requests_all.sum(&:amount_received)

      total_price = requests_all.sum(&:total_price)
      quantity = requests_all.count
      total = ((prescriber.partnership.to_f / 100.0) * amount_received).round(2)

      standard_account = prescriber.current_accounts.find_by(standard: true)
      partnership = standard_account ? total : total.round(-1)

      accumulated = if quantity >= @minimo_de_de_vendas_para_desacumular && total_price >= @valor_de_vendas_para_desacumular
        0
      else
        1
      end

      monthly_report = MonthlyReport.create!(
        total_price: total_price,
        partnership: partnership,
        discounts: discounts,
        accumulated: accumulated,
        quantity: quantity,
        closing_id: @closing.id,
        prescriber: prescriber,
        representative: representative
      )

      requests_all.map { |r|
        r.update(monthly_report: monthly_report, closing_id: @closing.id)
      }
    end

    envelope_number = MonthlyReport.where(accumulated: false).maximum(:envelope_number).to_i

    Request.where(entry_date: @start_date..@end_date).each do |request|
      next if request.monthly_report.accumulated

      envelope_number += 1
      request.monthly_report.update(envelope_number: envelope_number)
    end

    calculate_commission_on_sales
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

    monthly_reports&.each do |representative_id, sum_total_price, sum_quantity, partnership|
      comission = (sum_total_price.to_f * (partnership.to_f / 100)).round(2)

      monthly_report = MonthlyReport.find_by(
        closing_id: @closing.id,
        representative_id: representative_id
      )

      monthly_report&.update!(
        valor_total: sum_total_price,
        partnership: comission,
        quantity: sum_quantity,
        accumulated: false
      )
    end
  end

  def cleanup_temp_files
    %w[fc all group_duplicates].each do |prefix|
      Dir.glob(Rails.root.join("tmp", "#{prefix}*.csv")).each { |file| File.delete(file) }
    end
  end
end
