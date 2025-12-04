class CreateCustomers < ActiveRecord::Migration[7.1]
  def change
    create_table :customers do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.string :product_code
      t.string :source
      t.string :kind

      t.timestamps
    end
  end
end
