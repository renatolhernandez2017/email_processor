class CreateEmailFiles < ActiveRecord::Migration[7.1]
  def change
    create_table :email_files do |t|
      t.string :filename
      t.string :path
      t.string :sender
      t.string :status
      t.text :raw

      t.timestamps
    end
  end
end
