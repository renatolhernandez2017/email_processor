class BaseClosingPdf < Prawn::Document
  include Prawn::View
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper
  include Roundable

  def initialize(representatives, banks, current_closing)
    super()

    @representatives = representatives
    @banks = banks
    @current_closing = current_closing

    set_note_divisions
    stores_collections
    payment_for_representatives
    as_follows
  end

  def render
    generate_content
    super
  end

  def generate_content
    raise NotImplementedError, "Subclasses must implement `generate_content`"
  end

  private

  def stores_collections
    @store_collections = MonthlyReport.with_adjusted_billings(@current_closing.id)
    @store_total_quantity = @store_collections.map { |branch_name, stores| stores.first.total_number_of_requests }.first
    @store_total_value = @store_collections.map { |branch_name, stores| stores.first.total_branch_partnership }.first
  end

  def payment_for_representatives
    @payments = Closing.payment_for_representatives(@current_closing.id)
    @total_quantity = @payments.map { |name, payment| payment.sum(&:total_quantity) }.first
    @total_value = @payments.map { |name, payment| payment.sum(&:total_available_value) }.first
  end

  def as_follows
    @as_follows = Closing.as_follows(@current_closing.id)
    @as_follow_total_quantity = @as_follows.sum { |bank, as_follow| as_follow.sum(&:quantity) }
    @as_follow_total_value = @as_follows.sum { |bank, as_follow| as_follow.sum(&:available_value) }
  end

  def set_note_divisions
    @total_in_cash = []
    prescribers = []
    totals = []

    @representatives.each do |representative|
      prescribers[representative.id] = Prescriber.with_totals(@current_closing.id, representative.id)
      prescriber = prescribers[representative.id].first
      totals[representative.id] = Prescriber.get_totals(prescriber)
      available_value = totals[representative.id][:real_sale][:available_value].to_f
      @total_in_cash[representative.id] = divide_into_notes(available_value)
    end
  end
end
