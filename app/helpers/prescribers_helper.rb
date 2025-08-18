module PrescribersHelper
  def accumulated(prescriber)
    monthly_report = prescriber.monthly_reports.where(accumulated: true, closing_id: @current_closing.id).last

    return "<span class='text-red-500'>A</span>".html_safe if monthly_report.present?
    "D"
  end
end
