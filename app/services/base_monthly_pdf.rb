class BaseMonthlyPdf < Prawn::Document
  include Prawn::View
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper
  include MonthlyReportsHelper

  def initialize(representatives, closing, current_closing)
    super()
    @closing = closing
    @current_closing = current_closing
    @representatives = representatives
  end

  def render
    generate_content
    super
  end

  def generate_content
    raise NotImplementedError, "Subclasses must implement `generate_content`"
  end
end
