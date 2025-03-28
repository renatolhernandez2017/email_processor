class CreateRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :requests do |t|
      t.string :cdfil_id
      t.string :nrreq_id
      t.date :entry_date
      t.decimal :total_price, default: 0.0
      t.decimal :amount_received, default: 0.0
      t.decimal :total_fees, default: 0.0
      t.decimal :total_discounts, default: 0.0
      t.boolean :repeat, default: false
      t.date :payment_date
      t.decimal :value_for_report, default: 0.0
      t.string :rg
      t.string :patient_name

      t.timestamps
    end
  end
end
