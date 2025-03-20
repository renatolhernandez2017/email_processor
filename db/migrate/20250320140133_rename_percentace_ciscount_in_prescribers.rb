class RenamePercentaceCiscountInPrescribers < ActiveRecord::Migration[7.1]
  def change
    rename_column :prescribers, :percentage_ciscount, :percentage_discount
  end
end
