class CreateProcessingLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :processing_logs do |t|
      t.boolean :success, null: false, default: false
      t.jsonb :extracted_data
      t.text :error_message

      t.timestamps
    end
  end
end
