module NotesDivisions
  extend ActiveSupport::Concern

  included do
    before_action :load_representative_summaries, only: %i[select note_divisions]
  end

  private

  def load_representative_summaries
    @representative_summaries = {}
    @representatives = Representative.includes(:monthly_reports)
      .where(active: true)
      .where(monthly_reports: {closing_id: @current_closing.id, accumulated: false})
      .order(:name)

    @representatives.each do |representative|
      summary = NoteDivisionCalculator.new(representative.monthly_reports).call
      @representative_summaries[representative.id] = summary
    end
  end
end
