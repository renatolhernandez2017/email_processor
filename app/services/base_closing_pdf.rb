class BaseClosingPdf < Prawn::Document
  include Prawn::View
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper
  include ClosingsHelper
  include Roundable

  def initialize(representatives, banks, total_in_cash, current_month, current_closing)
    super()

    @representatives = representatives
    @banks = banks
    @total_in_cash = total_in_cash
    @current_month = current_month
    @current_closing = current_closing
  end

  def render
    generate_content
    super
  end

  def generate_content
    raise NotImplementedError, "Subclasses must implement `generate_content`"
  end
end
