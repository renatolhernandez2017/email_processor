class AddActiveToClosings < ActiveRecord::Migration[7.1]
  def change
    add_column :closings, :active, :boolean, default: false
  end
end
