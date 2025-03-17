class AddBankToCurrentAccounts < ActiveRecord::Migration[7.1]
  def change
    add_reference :current_accounts, :bank, foreign_key: true
  end
end
