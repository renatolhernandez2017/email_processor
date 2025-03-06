class AddPersonToAddresses < ActiveRecord::Migration[7.1]
  def change
    add_reference :addresses, :person, foreign_key: true
  end
end
