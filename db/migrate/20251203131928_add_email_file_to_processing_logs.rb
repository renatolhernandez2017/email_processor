class AddEmailFileToProcessingLogs < ActiveRecord::Migration[7.1]
  def change
    add_reference :processing_logs, :email_file, foreign_key: true
  end
end
