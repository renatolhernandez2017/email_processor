module ClosingsHelper
  def closing_date(closing)
    month_abbr = closing.closing.split("/")
    "#{t("view.months.#{month_abbr[0]}")}/#{month_abbr[1]}"
  end
end
