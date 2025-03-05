class CreatePeople < ActiveRecord::Migration[7.1]
  def change
    create_table :people do |t|
      t.string :kind
      t.string :name
      t.string :cnpj
      t.string :rg
      t.integer :representative_number
      t.string :class_concil
      t.string :uf_concil
      t.string :number_concil
      t.datetime :birthdate
      t.string :cpf

      t.timestamps
    end
  end
end
