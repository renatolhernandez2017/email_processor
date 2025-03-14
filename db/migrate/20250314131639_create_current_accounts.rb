class CreateCurrentAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :current_accounts do |t|
      t.boolean :standard, default: false
      t.string :favored

      t.timestamps
    end
  end
end
