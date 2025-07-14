module MonthlyReportsHelper
  def payment_method_display(monthly_report)
    return "Acumulado" if monthly_report.accumulated?
    return monthly_report.prescriber&.current_accounts&.find_by(standard: true)&.bank&.name if monthly_report.prescriber&.current_accounts&.find_by(standard: true).present?

    "Dinheiro"
  end
end
