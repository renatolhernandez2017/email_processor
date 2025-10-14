class MonthlyReport < ApplicationRecord
  audited

  include PgSearch::Model

  belongs_to :closing
  belongs_to :representative, optional: true
  belongs_to :prescriber

  has_many :requests, dependent: :destroy
  has_many :current_accounts, through: :prescriber

  validates :closing_id, :prescriber_id, presence: {message: " devem ser preenchidos!"}

  scope :with_adjusted_billings, ->(closing_id) {
    joins(:representative, requests: :branch)
      .where(closing_id: closing_id, accumulated: false, representatives: {active: true})
      .select(<<~SQL.squish)
        representatives.name AS representative_name,
        branches.name AS branch_name,
        COALESCE(SUM(monthly_reports.discounts), 0) AS total_discounts,
        MAX(representatives.partnership) AS commission,
        COALESCE(SUM(requests.amount_received), 0) AS total_requests,
        COALESCE(GREATEST(
          (SUM(requests.amount_received) / NULLIF(MAX(monthly_reports.total_price), 0)) * 
          (MAX(monthly_reports.partnership) - SUM(monthly_reports.discounts)), 0
        ), 0) AS branch_partnership,
        COALESCE(GREATEST(
          SUM(requests.amount_received) * MAX(representatives.partnership) / 100.0, 0
        ), 0) AS commission_payments_transfers,
        COUNT(requests.id) AS number_of_requests,
        COALESCE(SUM(COUNT(requests.id)) over(), 0)::integer AS total_number_of_requests,
        COALESCE(SUM(
          GREATEST(
            (SUM(requests.amount_received) / NULLIF(MAX(monthly_reports.total_price), 0)) * 
            (MAX(monthly_reports.partnership) - SUM(monthly_reports.discounts)), 0
          )) over(),
        0) AS total_branch_partnership
      SQL
      .group("representatives.name, branches.name")
      .group_by(&:branch_name)
  }
end
