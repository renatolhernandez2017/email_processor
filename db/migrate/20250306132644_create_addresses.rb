class CreateAddresses < ActiveRecord::Migration[7.1]
  def change
    create_table :addresses do |t|
      t.string :street
      t.string :district
      t.string :number
      t.string :complement
      t.string :city
      t.string :uf
      t.string :zip_code
      t.string :phone
      t.string :cellphone

      t.timestamps
    end
  end
end
