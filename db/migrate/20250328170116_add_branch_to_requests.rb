class AddBranchToRequests < ActiveRecord::Migration[7.1]
  def change
    add_reference :requests, :branch, foreign_key: true
    add_reference :requests, :prescriber, foreign_key: true
    add_reference :requests, :representative, foreign_key: true
    add_reference :requests, :monthly_report, foreign_key: true
  end
end
