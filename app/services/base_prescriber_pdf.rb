class BasePrescriberPdf < Prawn::Document
  include Prawn::View
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper

  def initialize(prescriber, current_closing)
    super()

    @prescriber = prescriber
    @current_closing = current_closing

    load_prescribers_for_representatives
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
    @representative = @prescriber.representative
    prescribers = @representative.prescribers.where(representative_id: @representative.id)
    @prescribers = prescribers.with_totals(@current_closing.id).where(id: @prescriber.id)
  end
end
