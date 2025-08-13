class MonthlyReport < ApplicationRecord
  audited

  include PgSearch::Model
  include Roundable

  belongs_to :closing
  belongs_to :representative, optional: true
  belongs_to :prescriber

  has_many :requests, dependent: :destroy
  has_many :current_accounts, through: :prescriber

  validates :closing_id, :prescriber_id, presence: {message: " devem ser preenchidos!"}

  scope :with_adjusted_billings, ->(closing_id) {
    joins(:representative, requests: :branch)
      .where(closing_id: closing_id, accumulated: false)
      .select(<<~SQL.squish)
        monthly_reports.representative_id,
        representatives.name AS representative_name,
        branches.name AS branch_name,
        COALESCE(SUM(DISTINCT monthly_reports.discounts), 0) AS total_discounts,
        MAX(DISTINCT representatives.partnership) AS commission,
        COALESCE(SUM(DISTINCT requests.amount_received), 0) AS total_requests,
        COALESCE(GREATEST(
          (SUM(DISTINCT requests.amount_received) / NULLIF(MAX(DISTINCT monthly_reports.total_price), 0)) * 
          (MAX(DISTINCT monthly_reports.partnership) - SUM(DISTINCT monthly_reports.discounts)), 0
        ), 0) AS branch_partnership,
        COALESCE(GREATEST(
          SUM(DISTINCT requests.amount_received) * MAX(DISTINCT representatives.partnership) / 100.0, 0
        ), 0) AS commission_payments_transfers,
        COUNT(DISTINCT requests.id) AS number_of_requests,
        COALESCE(SUM(COUNT(DISTINCT requests.id)) over(), 0)::integer AS total_number_of_requests,
        COALESCE(SUM(
          GREATEST(
            (SUM(DISTINCT requests.amount_received) / NULLIF(MAX(DISTINCT monthly_reports.total_price), 0)) * 
            (MAX(DISTINCT monthly_reports.partnership) - SUM(DISTINCT monthly_reports.discounts)), 0
          )) over(),
        0) AS total_branch_partnership
      SQL
      .group("monthly_reports.representative_id, representatives.name, branches.name")
      .group_by(&:branch_name)
  }
end
