class AddIndexToPrescribersCrm < ActiveRecord::Migration[7.1]
  def change
    add_index :prescribers, :crm, unique: true
  end
end
