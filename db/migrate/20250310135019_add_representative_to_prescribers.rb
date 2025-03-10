class AddRepresentativeToPrescribers < ActiveRecord::Migration[7.1]
  def change
    add_reference :prescribers, :representative, foreign_key: true
  end
end
