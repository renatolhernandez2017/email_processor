class ClosingProcessor
  include Roundable

  def initialize(closing)
    @closing = closing
    @start_date = Date.parse(@closing.start_date.strftime("%Y-%m-%d"))
    @end_date = Date.parse(@closing.end_date.strftime("%Y-%m-%d"))
    @periodo_para_desacumular = 10
    @valor_de_vendas_para_desacumular = 667.0
    @minimo_de_de_vendas_para_desacumular = 1
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
    ImportCsvService.new("#{Rails.root}/tmp/group_duplicates.csv").import!

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

  def create_monthly_reports
    requests = Request.where(entry_date: @start_date..@end_date).group_by(&:prescriber_id)

    requests.each_with_index do |(prescriber_id, requests_all), index|
      prescriber = Prescriber.find(prescriber_id)
      representative = requests_all.last.representative
      monthly_report = MonthlyReport.find_or_create_by(closing_id: @closing.id, prescriber: prescriber, representative: representative)

      requests_all.map { |r| r.update(monthly_report_id: monthly_report.id, closing_id: @closing.id) }
    end
  end

  def update_requests
    Request.where("value_for_report < amount_received")
      .where("value_for_report >= ?", 25.0)
      .where.not(payment_date: nil)
      .update_all("amount_received = value_for_report")
  end

  def adjust_monthly_reports
    monthly_reports = MonthlyReport.joins(:prescriber).where(closing_id: @closing.id)

    monthly_reports.where("prescribers.repetitions = 0.0").each do |monthly_report|
      prescriber = monthly_report.prescriber
      available_requests = prescriber.requests.where(repeat: true)

      available_requests.destroy_all
    end

    monthly_reports.where("prescribers.repetitions > 0.0").each do |monthly_report|
      prescriber = monthly_report.prescriber
      repetitions = prescriber.repetitions.to_f / 100.0
      discount_percentage = prescriber.consider_discount_of_up_to.to_f / 100.0

      available_requests = prescriber.requests.where(repeat: true)
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
      requests = prescriber.requests
      standard_account = prescriber.current_accounts.find_by(standard: true)
      amount_received = requests.sum(&:amount_received)
      total = ((prescriber.partnership.to_f / 100.0) * amount_received).round(2)
      partnership = standard_account.present? ? total : total.round(-1)
      discounts = requests.sum(&:total_discounts) * ([prescriber.discount_of_up_to, 1].max / 100.0)
      quantity = requests.where.not(payment_date: nil).count

      accumulated = if quantity >= @minimo_de_de_vendas_para_desacumular && amount_received >= @valor_de_vendas_para_desacumular
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
    envelope_number = MonthlyReport.where(accumulated: false).maximum(:envelope_number).to_i

    Request.includes(:prescriber, :monthly_report).where(entry_date: @start_date..@end_date)
      .where.not(monthly_report_id: nil).order("prescribers.name ASC").each do |request|
      next if request.monthly_report.accumulated

      envelope_number += 1
      request.monthly_report.update(envelope_number: envelope_number)
    end
  end

  def cleanup_temp_files
    %w[fc all group_duplicates].each do |prefix|
      Dir.glob(Rails.root.join("tmp", "#{prefix}*.csv")).each { |file| File.delete(file) }
    end
  end
end
