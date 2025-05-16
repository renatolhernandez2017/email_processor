class AddNumberToRepresentatives < ActiveRecord::Migration[7.1]
  def change
    add_column :representatives, :number, :string
  end
end
