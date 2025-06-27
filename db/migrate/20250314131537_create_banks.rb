class CreateBanks < ActiveRecord::Migration[7.1]
  def change
    create_table :banks do |t|
      t.string :name
      t.boolean :rounding, default: false
      t.string :agency_number
      t.string :account_number

      t.timestamps
    end
  end
end
