class AddRepresentativeToAddresses < ActiveRecord::Migration[7.1]
  def change
    add_reference :addresses, :representative, foreign_key: true
  end
end
