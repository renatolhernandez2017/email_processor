class AddActiveToRepresentatives < ActiveRecord::Migration[7.1]
  def change
    add_column :representatives, :active, :boolean, default: false
  end
end
