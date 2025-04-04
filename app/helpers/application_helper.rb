module ApplicationHelper
  include Pagy::Frontend

  def representative_active_tab?
    active_paths = [
      {action: "index", path: representatives_path},
      {action: "show", path: -> { representative_path(id: params[:id]) if params[:id].present? }},
      {action: "monthly_report", path: -> { monthly_report_representative_path(id: params[:id]) if params[:id].present? }},
      {action: "patient_listing", path: -> { patient_listing_representative_path(id: params[:id]) if params[:id].present? }},
      {action: "summary_patient_listing", path: -> { summary_patient_listing_representative_path(id: params[:id]) if params[:id].present? }}
    ]

    if active_paths.any? do |path|
      resolved_path = path[:path].is_a?(Proc) ? path[:path].call : path[:path]
      params[:action] == path[:action] && current_page?(resolved_path)
    end
      "bg-primary checked text-white"
    else
      ""
    end
  end

  def formatted_percentage(value)
    number_to_percentage(value, precision: 2)
  end
end
