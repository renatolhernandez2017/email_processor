class AddClosingToRequests < ActiveRecord::Migration[7.1]
  def change
    add_reference :requests, :closing, foreign_key: true
  end
end
