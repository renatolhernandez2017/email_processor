class ClosingProcessor
  def initialize(closing)
    @closing = closing
    @start_date = @closing.start_date.strftime("%Y-%m-%d")
    @end_date = @closing.end_date.strftime("%Y-%m-%d")
  end

  def call
    broadcast("Iniciando fechamento...")
    execute_script

    Importers::GroupDuplicates.new("#{Rails.root}/public/all.csv").import!

    ["fc01000", "fc08000"].each do |file|
      ImportCsvService.new("#{Rails.root}/public/#{file}.csv").import!
      sleep 3
    end

    broadcast("Gerando requisições dos prescritores...")
    ImportCsvService.new("#{Rails.root}/public/group_duplicates.csv").import!

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
    requests = Request.where(entry_date: @start_date..@end_date).group_by(&:prescriber_id)

    requests.each do |prescriber_id, requests_all|
      prescriber = Prescriber.find(prescriber_id)
      envelope_number = MonthlyReport.last&.envelope_number || 0
      discount_of_up_to = [prescriber.discount_of_up_to, 1].max
      discounts = requests_all.sum(&:total_discounts) * (discount_of_up_to / 100.0)
      representative = requests_all.last.representative
      accumulated = !(requests_all.count > 4 && requests_all.sum(&:amount_received) >= 166.66)
      total = requests_all.sum(&:total_price) * (prescriber.partnership.to_f / 100.0)

      standard_account = prescriber.current_accounts.find_by(standard: true)
      partnership = standard_account ? total : total.round(-1)

      monthly_report = MonthlyReport.create!(
        total_price: requests_all.sum(&:total_price),
        partnership: partnership,
        discounts: discounts,
        accumulated: accumulated,
        quantity: requests_all.count,
        envelope_number: envelope_number + 1,
        closing_id: @closing.id,
        prescriber: prescriber,
        representative: representative
      )

      requests_all.map { |r| r.update(monthly_report: monthly_report) }
    end
  end

  def cleanup_temp_files
    %w[fc all group_duplicates].each do |prefix|
      Dir.glob(Rails.root.join("public", "#{prefix}*.csv")).each { |file| File.delete(file) }
    end
  end
end
