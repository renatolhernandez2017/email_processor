class CreateMonthlyReports < ActiveRecord::Migration[7.1]
  def change
    create_table :monthly_reports do |t|
      t.decimal :total_price, default: 0.0
      t.decimal :partnership, default: 0.0
      t.decimal :discounts, default: 0.0
      t.decimal :balance, default: 0.0
      t.boolean :accumulated, default: true
      t.text :report
      t.integer :quantity
      t.integer :envelope_number

      t.timestamps
    end
  end
end
