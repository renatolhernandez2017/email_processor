module ApplicationHelper
  include Pagy::Frontend

  def active_tab?(controller_name)
    tab_routes = send(:"tab_#{controller_name}")

    active_paths(tab_routes)
  end

  def tab_closing
    [
      {action: "index", path: -> { root_path }},
      {action: "index", path: -> { closings_path }},
      {action: "note_divisions", path: -> { note_divisions_closings_path }},
      {action: "deposits_in_banks", path: -> { deposits_in_banks_closings_path }},
      {action: "closing_audit", path: -> { closing_audit_closings_path }}
    ]
  end

  def tab_representative
    [
      {action: "index", path: -> { representatives_path }},
      {action: "show", path: -> { representative_path(id: params[:id]) if params[:id].present? }},
      {action: "monthly_report", path: -> { monthly_report_representative_path(id: params[:id]) if params[:id].present? }},
      {action: "patient_listing", path: -> { patient_listing_representative_path(id: params[:id]) if params[:id].present? }},
      {action: "summary_patient_listing", path: -> { summary_patient_listing_representative_path(id: params[:id]) if params[:id].present? }},
      {action: "unaccumulated_addresses", path: -> { unaccumulated_addresses_representative_path(id: params[:id]) if params[:id].present? }}
    ]
  end

  def tab_prescriber
    [
      {action: "index", path: -> { prescribers_path }},
      {action: "show", path: -> { prescriber_path(id: params[:id]) if params[:id].present? }}
    ]
  end

  def tab_branch
    [
      {action: "index", path: -> { branches_path }}
    ]
  end

  def tab_discount
    [
      {action: "index", path: -> { discounts_path }}
    ]
  end

  def formatted_percentage(value)
    number_to_percentage(value, precision: 2)
  end

  def set_closing_date
    month_abbr = @current_closing.closing.split("/")
    "#{t("view.months.#{month_abbr[0]}")}/#{month_abbr[1]}"
  end

  private

  def active_paths(paths)
    if paths.any? do |path|
      resolved_path = path[:path].is_a?(Proc) ? path[:path].call : path[:path]
      params[:action] == path[:action] && current_page?(resolved_path)
    end
      "bg-primary checked text-white"
    else
      ""
    end
  end
end
