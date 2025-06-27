class CreateClosings < ActiveRecord::Migration[7.1]
  def change
    create_table :closings do |t|
      t.datetime :start_date
      t.datetime :end_date
      t.string :closing, limit: 20
      t.integer :last_envelope
      t.boolean :active, default: false

      t.timestamps
    end
  end
end
