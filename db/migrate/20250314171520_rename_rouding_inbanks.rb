class RenameRoudingInbanks < ActiveRecord::Migration[7.1]
  def change
    rename_column :banks, :rouding, :rounding
    remove_column :banks, :bank_number, :string
    change_column_default :banks, :rounding, default: false
  end
end
