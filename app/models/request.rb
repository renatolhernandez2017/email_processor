class Request < ApplicationRecord
  audited

  include ActionView::Helpers::NumberHelper
  include PgSearch::Model

  belongs_to :branch, optional: true
  belongs_to :monthly_report, optional: true
  belongs_to :prescriber, optional: true
  belongs_to :representative, optional: true

  has_one :discount, dependent: :destroy

  scope :eligible, ->(monthly_report) {
    min_payment_date = monthly_report.requests.minimum(:payment_date) - 45.days

    where(monthly_report_id: monthly_report.id)
      .or(
        where(
          monthly_report_id: nil,
          entry_date: min_payment_date,
          repeat: false,
          payment_date: nil,
          total_discounts: 0.0
        )
      )
  }

  def total_amount_for_report
    return value_for_report if value_for_report > 24.0

    if value_for_report <= 24.0
      return total_price if total_discounts <= 0.0
      amount_received if total_discounts > 0.0
    end
  end

  def set_payment_date(request)
    if request.payment_date
      request.payment_date.strftime("%d/%m/%y") if request.amount_received
    else
      "  /  /  "
    end
  end

  def set_price(request)
    if request.entry_date
      number_to_currency(request.total_amount_for_report) if request.amount_received
    elsif !request.entry_date && request.total_price
      number_to_currency(request.total_price)
    end
  end
end
