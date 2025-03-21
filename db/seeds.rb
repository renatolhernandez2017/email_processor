puts "apagando dados antigos..."
User.destroy_all
Closing.destroy_all
Address.destroy_all
Prescriber.destroy_all
Representative.destroy_all
Branch.destroy_all
CurrentAccount.destroy_all
Bank.destroy_all
Discount.destroy_all

puts "Criando user Admin"
User.create!(name: "renato", email: "renatolhernandez@gmail.com", password: "120711", role: "admin")

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

puts "Criando Representantes com Endereços, Filiais, Prescritores, Bancos, Contas Correntes e Descontos"
sp_cities = [
  "São Paulo", "Vila Mariana", "Tatuape", "Lapa", "Santo Amaro",
  "Angélica", "Santana", "Bauru", "Diadema", "Piracicaba", "Jundiaí",
  "Suzano", "Barueri", "Indaiatuba", "Carapicuíba"
]

15.times do |i|
  branch = Branch.create!(
    name: sp_cities[i - 1],
    branch_number: i + 1
  )

  bank = Bank.create!(
    name: I18n.t("bank.names").values.sample,
    agency_number: Faker::Number.number(digits: 4),
    account_number: Faker::Bank.account_number
  )

  representative = Representative.create!(
    name: Faker::Name.name,
    branch_id: branch.id
  )

  CurrentAccount.create!(
    bank_id: bank.id,
    representative_id: representative.id,
    favored: representative.name
  )

  prescriber = Prescriber.create!(
    name: Faker::Name.name,
    council: "#{Faker::Name.first_name} - Conselho",
    secretary: "#{Faker::Name.first_name} - Secretaria",
    note: Faker::Lorem.sentence,
    class_council: rand(1..9),
    uf_council: Faker::Address.state_abbr,
    number_council: Array.new(6) { rand(1..9) }.join(" "),
    representative_id: representative.id
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
    fax: Faker::PhoneNumber.phone_number,
    prescriber_id: prescriber.id
  )

  Discount.create!(
    description: Faker::Commerce.product_name,
    branch_id: branch.id,
    prescriber_id: prescriber.id
  )
end

puts "FIM!"
