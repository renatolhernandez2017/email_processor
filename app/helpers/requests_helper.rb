module RequestsHelper
  include ActionView::Helpers::NumberHelper
  include Roundable

  def set_payment_date(request)
    if request.payment_date?
      request.payment_date.strftime("%d/%m/%y")
    else
      "  /  /  "
    end
  end

  def set_price(request)
    if request.payment_date?
      number_to_currency(request.total_amount_for_report.round)
    else
      number_to_currency(request.total_price.round)
    end
  end
end
