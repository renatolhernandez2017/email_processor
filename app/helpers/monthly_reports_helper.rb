module MonthlyReportsHelper
  include ActionView::Helpers::NumberHelper
  include Roundable

  def payment_method_display(monthly_report)
    prescriber = monthly_report.prescriber
    current_account = prescriber.current_accounts.find_by(standard: true)

    if monthly_report.accumulated?
      "Acumulado"
    elsif !monthly_report.accumulated? && current_account.present?
      current_account.bank.name
    else
      "Dinheiro"
    end
  end
end
