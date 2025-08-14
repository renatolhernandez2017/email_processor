class BaseBranchPdf < Prawn::Document
  include Prawn::View
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper
  include ApplicationHelper

  def initialize(branches, current_closing)
    super()

    @branches = branches
    @current_closing = current_closing

    set_branches
  end

  def render
    generate_content
    super
  end

  def generate_content
    raise NotImplementedError, "Subclasses must implement `generate_content`"
  end

  private

  def set_branches
    @loose = Request.with_adjusted_totals(@current_closing.start_date, @current_closing.end_date, @current_closing.id)
    @total_revenue = Request.with_adjusted_totals_billings(@current_closing.start_date, @current_closing.end_date, @current_closing.id)
    @with_partnership = MonthlyReport.with_adjusted_billings(@current_closing.id)
  end
end
