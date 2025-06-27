class Closing < ApplicationRecord
  audited

  include PgSearch::Model
  include LoadMonthlyReports

  has_many :monthly_reports, dependent: :destroy
  has_many :requests, through: :monthly_reports

  validates :start_date, presence: {message: " deve estar preenchido!"}
  validates :closing, presence: {message: " deve estar preenchido!"}, uniqueness: {message: " já está cadastrado!"}

  def monthly_reports_false(closing_id, eager_load = [])
    scoped_monthly_reports(closing_id, eager_load).where(accumulated: false)
  end

  def set_current_accounts(closing_id)
    CurrentAccount.includes(:bank, prescriber: [:representative, :monthly_reports])
      .where(monthly_reports: {closing_id: closing_id, accumulated: false}, standard: true)
      .order("banks.name ASC")
      .group_by { |current_account| current_account.bank.name }
      .map do |bank_name, accounts|
        {
          name: bank_name,
          accounts: accounts
        }
      end
  end

  def store_collections(closing_id)
    monthly_reports_false(closing_id, [:requests, {representative: [:branch, :prescriber]}])
      .group_by { |m| m.prescriber&.representative&.branch&.name }
      .map do |branch, reports|
        total_price = reports.sum(&:total_price)
        total_partnership_discounts = reports.sum(&:partnership) - reports.sum(&:discounts)
        total_received = reports.sum { |report| report.requests.sum(&:amount_received) / total_price }
        {
          name: branch,
          count: reports.sum(&:quantity),
          total: reports.sum { |report| (total_received * total_partnership_discounts) }.to_f
        }
      end
  end

  def payment_for_representatives(closing_id)
    monthly_reports_false(closing_id, [prescriber: {current_accounts: :bank}])
      .where.not(representative_id: nil)
      .group_by { |m| m.representative.name }
      .map do |representative, reports|
        {
          name: representative,
          quantity: reports.sum(&:quantity),
          value: reports.sum { |m| m.available_value }
        }
      end
  end

  def as_follows(closing_id)
    monthly_reports_false(closing_id, [prescriber: {current_accounts: :bank}])
      .group_by { |m| m.prescriber&.current_accounts&.find_by(standard: true)&.bank&.name }
      .map do |bank, reports|
        {
          name: bank,
          count: reports.count,
          value: reports.sum { |report| report.available_value }
        }
      end
  end

  def perform_closing(closing)
    @closing = closing
    start_date = @closing.start_date.strftime("%Y-%m-%d")
    end_date = @closing.end_date.strftime("%Y-%m-%d")

    success = system("#{Rails.root}/script/converter.sh #{start_date} #{end_date}")
    sleep 2

    raise "Erro ao executar o script de conversão" unless success

    # agrupa os dados repetidos
    path = "#{Rails.root}/tmp/all.csv"
    Importers::GroupDuplicates.new(path).import!
    sleep 2

    # agora cria as Filiais e os Representantes
    ["fc01000", "fc08000"].each do |file|
      path = "#{Rails.root}/tmp/#{file}.csv"
      ImportCsvService.new(path).import!
    end
    sleep 2

    # agora cria as Requisições dos Prescritores
    path = "#{Rails.root}/tmp/group_duplicates.csv"
    ImportCsvService.new(path).import!
    sleep 2

    # agora cria os relatórios mensais
    create_monthly_reports(start_date, end_date)
    sleep 2

    # agora apagar os arquivos temporários fc*.csv e group_duplicates*.csv
    # %w[fc all group_duplicates].each do |prefix|
    #   Dir.glob(Rails.root.join("tmp", "#{prefix}*.csv")).each do |file|
    #     File.delete(file)
    #   end
    # end
  end

  def create_monthly_reports(start_date, end_date)
    requests = Request.where(entry_date: start_date..end_date).group_by(&:prescriber_id)

    requests.each do |prescriber_id, requests_all|
      prescriber = Prescriber.find(prescriber_id)
      envelope_number = MonthlyReport.last&.envelope_number || 0
      discounts = requests_all.sum(&:total_discounts) * (prescriber.discount_of_up_to / 100.0)
      representative = requests_all.last.representative
      accumulated = !(requests_all.count > 4 && requests_all.sum(&:amount_received) >= 166.66)
      total = requests_all.sum(&:total_price) * (prescriber.partnership.to_f / 100.0)

      partnership = if prescriber.current_accounts.find_by(standard: true).present?
        total
      else
        total.round(-1)
      end

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
end
