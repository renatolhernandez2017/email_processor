class BaseRepresentativePdf < Prawn::Document
  include Prawn::View
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper
  include Roundable

  def initialize(representatives, current_closing, title, filter)
    super()

    @representatives = representatives
    @current_closing = current_closing

    if title == "patient_listing" || title == "summary_patient_listing" || title == "address_report" || title == "tags"
      load_prescribers_for_representatives(filter)
    else
      load_totals_for_representatives(filter)
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

  def load_prescribers_for_representatives(filter)
    @prescribers = []

    @representatives.each do |representative|
      prescribers = representative.prescribers.where(representative_id: representative.id)
      @prescribers[representative.id] = prescribers.with_totals(@current_closing.id, filter)
    end
  end

  def load_totals_for_representatives(filter)
    @totals_by_bank = []
    @totals_by_store = []
    @total_in_cash = []
    @prescribers = []
    @totals = []
    @totals_from_banks = []
    @totals_from_stores = []

    @representatives.each do |representative|
      prescribers = representative.prescribers.where(representative_id: representative.id)
      @prescribers[representative.id] = prescribers.with_totals(@current_closing.id, filter)

      prescriber = @prescribers[representative.id].first
      @totals[representative.id] = prescribers.get_totals(prescriber)

      @totals_by_bank[representative.id] = prescribers.totals_by_bank_for_representatives(@current_closing.id, filter)
      @totals_from_banks[representative.id] = prescribers.totals_by_bank_store(@totals_by_bank[representative.id])

      @totals_by_store[representative.id] = prescribers.totals_by_store_for_representatives(@current_closing.id, filter)
      @totals_from_stores[representative.id] = prescribers.totals_by_bank_store(@totals_by_store[representative.id])

      available_value = @totals[representative.id][:real_sale][:available_value].to_f.round
      @total_in_cash[representative.id] = divide_into_notes(available_value)
    end
  end
end
