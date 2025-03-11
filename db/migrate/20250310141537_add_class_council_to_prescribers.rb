class AddClassCouncilToPrescribers < ActiveRecord::Migration[7.1]
  def change
    add_column :prescribers, :class_council, :string, limit: 1
    add_column :prescribers, :number_council, :string
    add_column :prescribers, :uf_council, :string, limit: 2
    add_column :prescribers, :birthdate, :date
  end
end
