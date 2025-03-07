class CreateBranches < ActiveRecord::Migration[7.1]
  def change
    create_table :branches do |t|
      t.string :name
      t.integer :branch_number
      t.decimal :discount_request

      t.timestamps
    end
  end
end
