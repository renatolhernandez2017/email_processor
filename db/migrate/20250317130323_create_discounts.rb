class CreateDiscounts < ActiveRecord::Migration[7.1]
  def change
    create_table :discounts do |t|
      t.boolean :visible, default: false
      t.decimal :price, default: 0.0
      t.string :description

      t.timestamps
    end
  end
end
