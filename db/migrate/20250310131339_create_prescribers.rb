class CreatePrescribers < ActiveRecord::Migration[7.1]
  def change
    create_table :prescribers do |t|
      t.string :name
      t.decimal :partnership, default: 0.0
      t.string :secretary
      t.string :note
      t.decimal :consider_discount_of_up_to, default: 0.0
      t.decimal :percentage_ciscount, default: 0.0
      t.decimal :repetitions, default: 0.0
      t.boolean :allows_changes_values, default: false
      t.decimal :discount_value, default: 0.0

      t.timestamps
    end
  end
end
