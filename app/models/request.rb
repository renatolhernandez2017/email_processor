class Request < ApplicationRecord
  audited

  include ActionView::Helpers::NumberHelper
  include PgSearch::Model

  belongs_to :branch, optional: true
  belongs_to :monthly_report, optional: true
  belongs_to :prescriber, optional: true
  belongs_to :representative, optional: true

  scope :with_adjusted_totals, ->(start_date, end_date) {
    joins(:branch)
      .select(<<~SQL.squish)
        branch_id,
        SUM(total_price) AS total_price,
        COUNT(requests.id) AS quantity,
        SUM(amount_received) AS amount_received,
        SUM(total_discounts) AS total_discounts,
        SUM(total_fees) AS total_fees,
        CASE
          WHEN branches.branch_number != 13 THEN SUM(total_price) / COUNT(requests.id)
          ELSE (SUM(total_price) / 0.85) / COUNT(requests.id)
        END AS adjusted_revenue_value,
        CASE
          WHEN branches.branch_number != 13 THEN SUM(total_price)
          ELSE SUM(total_price) / 0.85
        END AS adjusted_total_orders
      SQL
      .where(entry_date: start_date..end_date)
      .group(:branch_id, "branches.branch_number")
      .index_by(&:branch_id)
  }

  scope :with_adjusted_totals_billings, ->(start_date, end_date) {
    joins(:branch)
      .select(<<~SQL.squish)
        branch_id,
        SUM(amount_received) AS amount_received,
        CASE
          WHEN branches.branch_number != 13 THEN SUM(amount_received)
          ELSE SUM(amount_received) / 0.85
        END AS billing
      SQL
      .where(payment_date: start_date..end_date)
      .group(:branch_id, "branches.branch_number")
      .index_by(&:branch_id)
  }

  def total_amount_for_report
    return value_for_report if value_for_report > 24.0

    (total_discounts <= 0.0) ? total_price : amount_received
  end

  def set_payment_date(request)
    if request.payment_date?
      request.payment_date.strftime("%d/%m/%y")
    else
      "  /  /  "
    end
  end

  def set_price(request)
    if request.payment_date?
      number_to_currency(request.total_amount_for_report)
    else
      number_to_currency(request.total_price)
    end
  end
end
