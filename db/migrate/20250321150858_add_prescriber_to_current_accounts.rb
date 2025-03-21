class AddPrescriberToCurrentAccounts < ActiveRecord::Migration[7.1]
  def change
    add_reference :current_accounts, :prescriber, foreign_key: true
  end
end
