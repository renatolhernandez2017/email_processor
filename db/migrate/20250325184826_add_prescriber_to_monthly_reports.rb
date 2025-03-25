class AddPrescriberToMonthlyReports < ActiveRecord::Migration[7.1]
  def change
    add_reference :monthly_reports, :prescriber, foreign_key: true
  end
end
