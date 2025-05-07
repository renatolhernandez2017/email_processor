module RepresentativeSummaries
  extend ActiveSupport::Concern

  included do
    before_action :load_representative_summaries, only: %i[monthly_report select note_divisions download_select_pdf]
  end

  private

  def load_representative_summaries
    @summary = {}
    @representatives = Representative.includes(:monthly_reports, :prescriber)
      .where(active: true)
      .where(monthly_reports: {closing_id: @current_closing.id, accumulated: false})
      .order("prescribers.name ASC")

    @representatives.each do |representative|
      @summary[representative.id] = representative.monthly_reports_load(representative, @current_closing.id)
    end
  end
end
