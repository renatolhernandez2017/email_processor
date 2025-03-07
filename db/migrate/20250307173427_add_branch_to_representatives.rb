class AddBranchToRepresentatives < ActiveRecord::Migration[7.1]
  def change
    add_reference :representatives, :branch, foreign_key: true
  end
end
