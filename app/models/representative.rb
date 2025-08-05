class Representative < ApplicationRecord
  audited

  include PgSearch::Model
  include Representative::Aggregations

  belongs_to :branch, optional: true

  has_one :address, dependent: :destroy

  has_many :prescribers, dependent: :destroy
  has_many :current_accounts, dependent: :destroy
  has_many :monthly_reports, dependent: :destroy
  has_many :requests, dependent: :destroy

  scope :with_totals, ->(closing_id) {
    left_joins(monthly_reports: :prescriber)
      .includes(:prescribers)
      .joins(<<~SQL.squish)
        LEFT JOIN current_accounts ca_standard
          ON ca_standard.prescriber_id = monthly_reports.prescriber_id
          AND ca_standard.standard = TRUE
      SQL
      .where(active: true, monthly_reports: {closing_id: closing_id})
      .group("representatives.id, representatives.name")
      .order("representatives.name ASC")
  }

  scope :monthly_reports, ->(closing_id, representative_ids) {
    MonthlyReport.joins(:prescriber)
      .where(closing_id: closing_id, accumulated: false, representative_id: representative_ids)
      .group(custom_group_sql)
      .select(custom_select_sql)
  }
end
