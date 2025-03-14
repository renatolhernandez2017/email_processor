class CreateBanks < ActiveRecord::Migration[7.1]
  def change
    create_table :banks do |t|
      t.string :name
      t.boolean :rouding
      t.string :bank_number
      t.string :agency_number
      t.string :account_number

      t.timestamps
    end
  end
end
