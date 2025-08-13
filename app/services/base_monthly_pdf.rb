class BaseMonthlyPdf < Prawn::Document
  include Prawn::View
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper
  include Roundable

  def initialize(representatives, closing, current_closing, selected_key)
    super()

    @closing = closing
    @current_closing = current_closing
    @representatives = representatives
    @title = selected_key

    if @title == "patient_listing" || @title == "summary_patient_listing" || @title == "address_report" || @title == "tags"
      load_prescribers_for_representatives
    else
      load_totals_for_representatives
    end
  end

  def render
    generate_content
    super
  end

  def generate_content
    raise NotImplementedError, "Subclasses must implement `generate_content`"
  end

  private

  def load_prescribers_for_representatives
    @prescribers = []

    @representatives.each do |representative|
      @prescribers[representative.id] = Prescriber.with_totals(@current_closing.id, representative.id)
    end
  end

  def load_totals_for_representatives
    @totals_by_bank = []
    @totals_by_store = []
    @total_in_cash = []
    @prescribers = []
    @totals = []
    @totals_from_banks = []
    @totals_from_stores = []

    @representatives.each do |representative|
      @prescribers[representative.id] = Prescriber.with_totals(@current_closing.id, representative.id)

      prescriber = @prescribers[representative.id].first
      @totals[representative.id] = Prescriber.get_totals(prescriber)

      @totals_by_bank[representative.id] = Prescriber.totals_by_bank_for_representatives(@current_closing.id, representative.id)
      totals_from_banks = @totals_by_bank[representative.id].first
      @totals_from_banks[representative.id] = Prescriber.totals_by_bank_store(totals_from_banks)

      @totals_by_store[representative.id] = Prescriber.totals_by_store_for_representatives(@current_closing.id, representative.id)
      totals_from_stores = @totals_by_store[representative.id].first
      @totals_from_stores[representative.id] = Prescriber.totals_by_bank_store(totals_from_stores)

      available_value = @totals[representative.id][:real_sale][:available_value].to_f
      @total_in_cash[representative.id] = divide_into_notes(available_value)
    end
  end
end
