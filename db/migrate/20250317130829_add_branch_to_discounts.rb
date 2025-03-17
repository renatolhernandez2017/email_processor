class AddBranchToDiscounts < ActiveRecord::Migration[7.1]
  def change
    add_reference :discounts, :branch, null: false, foreign_key: true
  end
end
