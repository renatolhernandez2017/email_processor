class Closing < ApplicationRecord
  audited

  include PgSearch::Model

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

  def perform_closing
    `#{Rails.root.join("script", "converter.sh")} &`
  end

  def this_month
    today = Date.today - 1
    find_by("end_date >= ? AND start_date <= ?", today, today)
  end

  def update_monthly_report
    @monthly_reports = MonthlyReport.includes(:prescriber, :requisition_discounts)
      .where(accumulated: false, closing_id: Closing.find_by(active: true))
      .where.not(representative_id: nil)

    @monthly_reports.each do |monthly_report|
      @requests = monthly_report.requests.eligible(monthly_report)

      patient_listing = ""

      @requests.each do |request|
        patient_listing << if request.patient_name.present?
          request.patient_name.lstrip[0..23].ljust(24)
        else
          "SN.".ljust(24)
        end

        patient_listing << if request.repeat
          "-R "
        else
          "   "
        end

        patient_listing << request.entry_date.strftime("%d/%m/%y") + " "

        if request.entry_date
          if request.amount_received.to_s && request.nrreq_id && request.branch.present?
            patient_listing << request.entry_date.strftime("%d/%m/%y")
            patient_listing << " " + request.total_amount_for_report.to_s.rjust(8) + " " + request.nrreq_id.rjust(8) + " " + request.branch.name
          end
        elsif !request.entry_date && request.total_price.to_s && request.nrreq_id && request.branch.present?
          patient_listing << "  /  /  "
          patient_listing << " " + request.total_price.to_s.rjust(8) + " " + request.nrreq_id.rjust(8) + " " + request.branch.name
        end

        patient_listing << "\n"
      end

      patient_listing << "\n\n"

      monthly_report.requisition_discounts.each do |discount|
        if discount&.visivel
          patient_listing << discount.description.ljust(25)
          patient_listing << discount.price.to_s.rjust(8)
        end
      end

      monthly_report.report = patient_listing
      monthly_report.save!
    end
  end

  private

  def scoped_monthly_reports(closing_id, eager_load)
    monthly_reports.includes(*eager_load)
      .where(closing_id: closing_id)
      .order("prescribers.name ASC")
  end
end
