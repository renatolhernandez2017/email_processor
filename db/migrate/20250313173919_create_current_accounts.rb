class CreateCurrentAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :current_accounts do |t|
      t.boolean :standard, default: false
      t.string :favored
      t.references :bank_information, foreign_key: true
      t.references :representative, foreign_key: true

      t.timestamps
    end
  end
end
