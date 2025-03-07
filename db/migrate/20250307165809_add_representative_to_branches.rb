class AddRepresentativeToBranches < ActiveRecord::Migration[7.1]
  def change
    add_reference :branches, :representative, foreign_key: true
  end
end
