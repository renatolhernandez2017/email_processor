class CreateBankInformations < ActiveRecord::Migration[7.1]
  def change
    create_table :bank_informations do |t|
      t.string :name
      t.boolean :rounding, default: false
      t.string :bank_number
      t.string :agency_number
      t.string :account_number

      t.timestamps
    end
  end
end
