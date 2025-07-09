module MonthlyReportsHelper
  def payment_method_display(monthly_report)
    return "Acumulado" if monthly_report.accumulated?
    return monthly_report.prescriber&.current_accounts&.find_by(standard: true)&.bank&.name if monthly_report.prescriber&.current_accounts&.find_by(standard: true).present?

    "Dinheiro"
  end

  def total_or_accumulated(monthly_reports)
    calculate_totals(monthly_reports)
  end

  def real_sale(all, accumulated)
    {
      count: all.size - accumulated.size,
      **calculate_differences(all, accumulated)
    }
  end

  private

  def calculate_totals(monthly_reports)
    {
      count: monthly_reports.count,
      quantity: monthly_reports.sum(&:quantity),
      total_price: number_to_currency(monthly_reports.sum(&:total_price)),
      partnership: number_to_currency(monthly_reports.sum(&:partnership)),
      discounts: number_to_currency(monthly_reports.sum(&:discounts)),
      available_value: number_to_currency(monthly_reports.sum(&:available_value))
    }
  end

  def calculate_differences(monthly_reports, accumulated)
    {
      quantity: monthly_reports.sum(&:quantity) - accumulated.sum(&:quantity),
      total_price: number_to_currency(monthly_reports.sum(&:total_price) - accumulated.sum(&:total_price)),
      partnership: number_to_currency(monthly_reports.sum(&:partnership) - accumulated.sum(&:partnership)),
      discounts: number_to_currency(monthly_reports.sum(&:discounts) - accumulated.sum(&:discounts)),
      available_value: number_to_currency(monthly_reports.sum(&:available_value) - accumulated.sum(&:available_value))
    }
  end
end
