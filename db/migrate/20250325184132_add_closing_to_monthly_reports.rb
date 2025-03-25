class AddClosingToMonthlyReports < ActiveRecord::Migration[7.1]
  def change
    add_reference :monthly_reports, :closing, foreign_key: true
  end
end
