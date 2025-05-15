class AddCrmToPrescriber < ActiveRecord::Migration[7.1]
  def change
    add_column :prescribers, :crm, :string
  end
end
