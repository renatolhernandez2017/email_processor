class AddMonthlyReportToDiscounts < ActiveRecord::Migration[7.1]
  def change
    add_reference :discounts, :monthly_report, foreign_key: true
  end
end
