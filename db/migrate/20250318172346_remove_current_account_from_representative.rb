class RemoveCurrentAccountFromRepresentative < ActiveRecord::Migration[7.1]
  def change
    remove_reference :representatives, :current_account
  end
end
