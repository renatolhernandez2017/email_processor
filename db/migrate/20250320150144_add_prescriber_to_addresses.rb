class AddPrescriberToAddresses < ActiveRecord::Migration[7.1]
  def change
    add_reference :addresses, :prescriber, foreign_key: true
  end
end
