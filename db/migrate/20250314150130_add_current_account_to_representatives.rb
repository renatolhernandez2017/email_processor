class AddCurrentAccountToRepresentatives < ActiveRecord::Migration[7.1]
  def change
    add_reference :representatives, :current_account, foreign_key: true
  end
end
