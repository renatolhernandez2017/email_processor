class BaseMonthlyPdf < Prawn::Document
  include Prawn::View
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper
  include MonthlyReportsHelper
  include Roundable

  def initialize(representatives, closing, current_closing)
    super()
    @closing = closing
    @current_closing = current_closing
    @representatives = representatives
    load_totals_for_representatives
  end

  def render
    generate_content
    super
  end

  def generate_content
    raise NotImplementedError, "Subclasses must implement `generate_content`"
  end

  private

  def load_totals_for_representatives
    @totals_by_bank = []
    @totals_by_store = []
    @total_in_cash = []
    @monthly_reports = []

    @representatives.each do |representative|
      @totals_by_bank[representative.id] = Representative.totals_by_bank_for_representatives(@current_closing.id, representative.id)
      @totals_by_store[representative.id] = Representative.totals_by_store_for_representatives(@current_closing.id, representative.id)
      total_cash = Representative.total_cash_for_representatives(@current_closing.id, representative.id)
      @total_in_cash[representative.id] = divide_into_notes(total_cash.sum(&:total_available_value).to_f)
      @monthly_reports[representative.id] = Representative.monthly_reports_for_representatives(@current_closing.id, representative.id)
    end
  end
end
