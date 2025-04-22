module ClosingsHelper
  def set_total_value(current_account)
    total = current_account.prescriber&.monthly_reports&.map { |m| m.available_value }&.sum
    number_to_currency(total)
  end

  def set_grand_total_value(accounts)
    grand_total = accounts.map do |account|
      account.prescriber&.monthly_reports&.map { |m| m.available_value }&.sum || 0
    end.sum

    number_to_currency(grand_total)
  end

  def closing_date(closing)
    month_abbr = closing.closing.split("/")
    "#{t("view.months.#{month_abbr[0]}")}/#{month_abbr[1]}"
  end
end
