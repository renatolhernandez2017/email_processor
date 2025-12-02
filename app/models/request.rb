class Request < ApplicationRecord
  audited

  include PgSearch::Model

  belongs_to :branch, optional: true
  belongs_to :closing, optional: true
  belongs_to :monthly_report, optional: true
  belongs_to :prescriber, optional: true
  belongs_to :representative, optional: true

  scope :with_adjusted_totals, ->(closing_id) {
    joins(:branch, :representative)
      .where(closing_id: closing_id)
      .select(<<~SQL.squish)
        requests.branch_id AS branch_id,
        COALESCE(SUM(total_price), 0) AS total_price,
        COALESCE(COUNT(requests.id), 0) AS quantity,
        COALESCE(SUM(amount_received), 0) AS amount_received,
        COALESCE(SUM(total_discounts), 0) AS total_discounts,
        COALESCE(SUM(total_fees), 0) AS total_fees,
        COALESCE(SUM(total_price) / COUNT(requests.id), 0) AS adjusted_revenue_value,
        COALESCE((SUM(total_price)), 0) AS total_orders
      SQL
      .group(:branch_id, "branches.branch_number")
      .index_by(&:branch_id)
  }

  scope :with_adjusted_totals_billings, ->(closing_id) {
    joins(:branch, :representative)
      .where(closing_id: closing_id)
      .select(<<~SQL.squish)
        requests.branch_id AS branch_id,
        COALESCE(SUM(amount_received) / 0.85, 0) AS amount_received,
        COALESCE((((SUM(amount_received)) - SUM(total_discounts) - SUM(total_fees))), 0) AS billing
      SQL
      .group(:branch_id, "branches.branch_number")
      .index_by(&:branch_id)
  }

  def total_amount_for_report
    return value_for_report if value_for_report > 24.0

    (total_discounts <= 0.0) ? total_price : amount_received
  end
end
