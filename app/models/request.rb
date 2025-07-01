class Request < ApplicationRecord
  audited

  include ActionView::Helpers::NumberHelper
  include PgSearch::Model

  belongs_to :branch, optional: true
  belongs_to :monthly_report, optional: true
  belongs_to :prescriber, optional: true
  belongs_to :representative, optional: true

  scope :with_adjusted_totals, ->(start_date:, end_date:) {
    select(<<~SQL.squish)
      branch_id,
      COUNT(id) AS quantity_revenue,
      SUM(total_discounts) AS total_discounts,
      SUM(total_fees) AS total_fees,
      CASE
        WHEN branch_id != 243724 THEN SUM(total_price) / COUNT(id)
        ELSE (SUM(total_price) / 0.85) / COUNT(id)
      END AS adjusted_revenue_value,
      CASE
        WHEN branch_id != 243724 THEN SUM(total_price)
        ELSE SUM(total_price) / 0.85
      END AS adjusted_total_orders
    SQL
      .where(entry_date: start_date..end_date)
      .group(:branch_id)
      .group_by(&:branch_id)
  }

  scope :with_adjusted_totals_billings, ->(start_date:, end_date:) {
    select(<<~SQL.squish)
      branch_id,
      SUM(amount_received) AS amount_received,
      CASE
        WHEN branch_id != 243724 THEN SUM(amount_received)
        ELSE (SUM(amount_received) / 0.85)
      END AS billing
    SQL
      .where(payment_date: start_date..end_date)
      .group(:branch_id)
      .group_by(&:branch_id)
  }

  def total_amount_for_report
    return value_for_report if value_for_report > 24.0

    total_discounts <= 0.0 ? total_price : amount_received
  end

  def set_payment_date(request)
    case
    when request.payment_date?
      request.payment_date.strftime("%d/%m/%y")
    else
      "  /  /  "
    end
  end

  def set_price(request)
    case
    when request.payment_date?
      number_to_currency(request.total_amount_for_report)
    when request.entry_date?
      number_to_currency(request.total_price)
    else
      0.0
    end
  end
end
