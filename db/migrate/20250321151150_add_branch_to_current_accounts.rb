class AddBranchToCurrentAccounts < ActiveRecord::Migration[7.1]
  def change
    add_reference :current_accounts, :branch, foreign_key: true
  end
end
