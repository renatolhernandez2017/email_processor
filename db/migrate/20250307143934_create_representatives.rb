class CreateRepresentatives < ActiveRecord::Migration[7.1]
  def change
    create_table :representatives do |t|
      t.string :name
      t.decimal :partnership, default: 0.0
      t.boolean :performs_closing, default: false

      t.timestamps
    end
  end
end
