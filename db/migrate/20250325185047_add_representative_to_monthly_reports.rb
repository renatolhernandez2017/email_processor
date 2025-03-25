class AddRepresentativeToMonthlyReports < ActiveRecord::Migration[7.1]
  def change
    add_reference :monthly_reports, :representative, foreign_key: true
  end
end
