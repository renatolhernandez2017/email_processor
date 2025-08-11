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

  scope :payment_for_representatives, ->(closing_id) {
    MonthlyReport.joins(:requests, :representative)
      .where(closing_id: closing_id, accumulated: false)
      .group("representatives.id", "representatives.name")
      .select(
        "representatives.id AS id",
        "representatives.name AS representative_name",
        custom_select
      )
      .group_by(&:representative_name)
  }

  scope :as_follows, ->(closing_id) {
    MonthlyReport.joins(:requests, current_accounts: :bank)
      .where(closing_id: closing_id, accumulated: false)
      .group("banks.name")
      .select(
        "banks.name AS bank_name",
        custom_select
      )
      .group_by(&:bank_name)
  }
end
