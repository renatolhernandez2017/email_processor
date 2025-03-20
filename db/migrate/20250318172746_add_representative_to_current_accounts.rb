class AddRepresentativeToCurrentAccounts < ActiveRecord::Migration[7.1]
  def change
    add_reference :current_accounts, :representative, foreign_key: true
  end
end
