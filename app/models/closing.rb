class Closing < ApplicationRecord
  audited

  include PgSearch::Model
  include Closing::Aggregations

  has_many :monthly_reports, dependent: :destroy
  has_many :requests, through: :monthly_reports

  validates :start_date, presence: {message: " deve estar preenchido!"}
  validates :closing, presence: {message: " deve estar preenchido!"}, uniqueness: {message: " já está cadastrado!"}

  scope :set_current_accounts, ->(closing_id) {
    CurrentAccount.joins(:bank, prescriber: [:representative])
      .joins(<<~SQL)
        LEFT JOIN (
          SELECT DISTINCT ON (prescriber_id) * FROM monthly_reports
          WHERE closing_id = #{closing_id.to_i}
          AND accumulated = false
          ORDER BY prescriber_id
        ) monthly_reports
        ON monthly_reports.prescriber_id = prescribers.id
      SQL
      .where(standard: true)
      .group("current_accounts.id", "banks.id", "representatives.name", "prescribers.representative_id")
      .having(sum_available_value_sql + " > 0")
      .select(custom_select_sql)
      .order("banks.name ASC")
      .uniq { |current_account| [current_account.favored] }
      .group_by(&:bank_name)
  }

  def monthly_reports_false(closing_id, eager_load = [])
    monthly_reports.includes(*eager_load)
      .where(closing_id: closing_id, accumulated: false)
      .order("prescribers.name ASC")
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
end
