puts "apagando dados antigos..."
User.destroy_all
Closing.destroy_all
Address.destroy_all
Representative.destroy_all
# Office.destroy_all

puts "Criando user Admin"
User.create!(name: "renato", email: "renatolhernandez@gmail.com", password: "123123", role: "admin")

puts "Criando Fechamento e relatórios"
date = Date.today

15.times do |i|
  start_date = (date << (i + 1)).next_day - 1
  end_date = (date << i).next_day - 1

  Closing.create!(
    start_date: start_date,
    end_date: end_date,
    closing: "#{end_date.strftime("%b")}/#{end_date.strftime("%y")}",
    last_envelope: i + 1,
    active: i == 0
  )
end

puts "Criando Representantes com Endereços e Filiais"
sp_cities = [
  "São Paulo", "Vila Mariana", "Tatuape", "Lapa", "Santo Amaro",
  "Angélica", "Santana", "Bauru", "Diadema", "Piracicaba", "Jundiaí",
  "Suzano", "Barueri", "Indaiatuba", "Carapicuíba"
]

15.times do |i|
  # office = Office.create!(
  #   name: sp_cities[i - 1],
  #   cdfil_id: i
  # )

  representative = Representative.create!(
    name: Faker::Name.name
  )

  Address.create!(
    street: Faker::Address.street_name,
    district: Faker::Address.community,
    number: Faker::Address.building_number,
    complement: Faker::Address.secondary_address,
    city: Faker::Address.city,
    uf: Faker::Address.state_abbr,
    zip_code: Faker::Address.zip_code,
    phone: Faker::PhoneNumber.phone_number,
    cellphone: Faker::PhoneNumber.cell_phone,
    fax: Faker::PhoneNumber.phone_number
  )
end

puts "FIM!"
