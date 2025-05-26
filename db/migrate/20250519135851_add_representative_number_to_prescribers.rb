class AddRepresentativeNumberToPrescribers < ActiveRecord::Migration[7.1]
  def change
    add_column :prescribers, :representative_number, :integer
    add_column :representatives, :number, :integer
  end
end
