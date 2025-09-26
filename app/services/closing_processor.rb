class ClosingProcessor
  def initialize(closing)
    @closing = closing
    @start_date = Date.parse(@closing.start_date.strftime("%Y-%m-%d"))
    @end_date = Date.parse(@closing.end_date.strftime("%Y-%m-%d"))
    @period_to_deaccumulate = 10
    @sales_value_to_disaccumulate = 667.0
    @minimum_of_sales_to_desacumular = 1
  end

  def call
    broadcast("Fechamento iniciado...", false, 1)
    execute_script

    Importers::GroupDuplicates.new("#{Rails.root}/tmp/all.csv").import!

    ["fc01000", "fc08000"].each do |file|
      ImportCsvService.new("#{Rails.root}/tmp/#{file}.csv").import!
      sleep 3
    end

    broadcast("Criando requisições dos prescritores...", false, 2)
    ImportCsvService.new("#{Rails.root}/tmp/group_duplicates.csv", @closing.id).import!

    broadcast("Criando relatórios mensais...", false, 3)
    update_requests
    create_monthly_reports

    broadcast("Atualizando relatórios mensais...", false, 4)
    adjust_monthly_reports
    update_monthly_reports
    cleanup_temp_files

    broadcast("Enumerando envelopes...", false, 5)
    enumerates_envelopes

    broadcast("Fechamento concluído com sucesso.", true, 6)
  rescue => e
    broadcast("Erro no fechamento: #{e.message}", true, 7)
  end

  def execute_script
    success = system("#{Rails.root}/script/converter.sh #{@start_date} #{@end_date}")

    raise "Erro ao executar script" unless success
  end

  def broadcast(message, status, step)
    ClosingChannel.broadcast_to("closing_#{@closing.id}", {message: message, status: status, step: step})
  end

  def update_requests
    Request.where("value_for_report < amount_received")
      .where("value_for_report >= ?", 25.0)
      .where.not(payment_date: nil)
      .update_all("amount_received = value_for_report")
  end

  def create_monthly_reports
    requests = Request.where(
      "(entry_date BETWEEN :start_date AND :end_date) OR (payment_date BETWEEN :start_date AND :end_date)",
      start_date: @start_date, end_date: @end_date
    ).group_by(&:prescriber_id)

    requests.each do |prescriber_id, requests_all|
      prescriber = Prescriber.find(prescriber_id)
      representative = prescriber.representative
      monthly_report = MonthlyReport.find_or_create_by(closing_id: @closing.id, prescriber: prescriber, representative: representative)

      requests_all.each do |request|
        request.update(monthly_report_id: monthly_report.id, representative_id: representative.id)
      end
    end
  end

  def adjust_monthly_reports
    monthly_reports = MonthlyReport.joins(:prescriber).where(closing_id: @closing.id)

    monthly_reports.where("prescribers.repetitions = 0.0").each do |monthly_report|
      prescriber = monthly_report.prescriber
      available_requests = prescriber.requests.where(repeat: true, closing_id: @closing.id).where.not(payment_date: nil)

      available_requests.destroy_all
    end

    monthly_reports.where("prescribers.repetitions > 0.0").each do |monthly_report|
      prescriber = monthly_report.prescriber
      repetitions = prescriber.repetitions.to_f / 100.0
      discount_percentage = prescriber.consider_discount_of_up_to.to_f / 100.0

      available_requests = prescriber.requests.where(repeat: true, closing_id: @closing.id)
        .where.not(payment_date: nil)
        .where("total_discounts <= total_price * ?", discount_percentage)
        .order(:total_price)

      limite = (repetitions * available_requests.count).to_i
      accepted_requests = available_requests.limit(limite)
      not_accepted_requests = available_requests.where.not(id: accepted_requests.ids)

      not_accepted_requests.destroy_all
    end
  end

  def update_monthly_reports
    monthly_reports = MonthlyReport.joins(:prescriber).where(closing_id: @closing.id)

    monthly_reports.each do |monthly_report|
      prescriber = monthly_report.prescriber

      requests = prescriber.requests.where(closing_id: @closing.id)
        .where.not(payment_date: nil).where(
          "(entry_date BETWEEN :start_date AND :end_date) OR (payment_date BETWEEN :start_date AND :end_date)",
          start_date: @start_date, end_date: @end_date
        )

      standard_account = prescriber.current_accounts.find_by(standard: true)
      amount_received = requests.sum { |r| r.amount_received.to_f.round }
      total = ((prescriber.partnership.to_f / 100.0) * amount_received).round(2)
      partnership = standard_account.present? ? total : total.round(-1)
      discounts = requests.sum(&:total_discounts) * ([prescriber.discount_of_up_to, 1].max / 100.0)
      quantity = requests.count

      accumulated = if quantity >= @minimum_of_sales_to_desacumular && amount_received >= @sales_value_to_disaccumulate
        0
      else
        1
      end

      if standard_account.blank?
        partnership = partnership.round
      end

      discounts = (discounts.to_f >= 25.0) ? discounts.round : 0.0
      accumulated = standard_account.present? ? 0 : accumulated

      monthly_report.update!(
        quantity: quantity,
        total_price: requests.sum(&:total_price).round,
        partnership: partnership,
        discounts: discounts,
        accumulated: accumulated
      )
    end
  end

  def enumerates_envelopes
    monthly_reports = MonthlyReport.joins(:prescriber, :representative)
      .where(accumulated: false, closing_id: @closing.id)
      .order("representatives.name ASC, prescribers.name ASC")

    envelope_number = MonthlyReport.where(accumulated: false).maximum(:envelope_number).to_i

    monthly_reports.group_by(&:representative_id).each do |_, monthly_reports_e|
      monthly_reports_e.each do |monthly_report|
        next if monthly_report.envelope_number.present?

        envelope_number += 1
        monthly_report.update(envelope_number: envelope_number)
      end
    end
  end

  def cleanup_temp_files
    %w[fc all group_duplicates].each do |prefix|
      Dir.glob(Rails.root.join("tmp", "#{prefix}*.csv")).each { |file| File.delete(file) }
    end
  end
end
