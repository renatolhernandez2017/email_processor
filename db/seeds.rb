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
MonthlyReport.destroy_all
Request.destroy_all

puts "Data atual"
date = Date.today

puts "Criando user Admin"
User.create!(name: "renato", email: "renatolhernandez@gmail.com", password: "120711", role: "admin")

puts "Criando Fechamento e relatórios, Representantes com Endereços, Filiais, Prescritores, Bancos, Contas Correntes e Descontos"
sp_cities = [
  "São Paulo", "Vila Mariana", "Tatuape", "Lapa", "Santo Amaro",
  "Angélica", "Santana", "Bauru", "Diadema", "Piracicaba", "Jundiaí",
  "Suzano", "Barueri", "Indaiatuba", "Carapicuíba"
]

15.times do |i|
  start_date = (date << (i + 1)).next_day - 1
  end_date = (date << i).next_day

  closing = Closing.create!(
    start_date: start_date,
    end_date: end_date,
    closing: "#{end_date.strftime("%b")}/#{end_date.strftime("%y")}",
    last_envelope: i + 1,
    active: i == 0
  )

  bank = Bank.create!(
    name: I18n.t("bank.names").values.sample,
    agency_number: Faker::Number.number(digits: 4),
    account_number: Faker::Bank.account_number
  )

  branch = Branch.create!(
    name: sp_cities[i - 1],
    branch_number: i + 1,
    discount_request: Faker::Commerce.price(range: 1.0..10.0).round(2)
  )

  CurrentAccount.create!(
    bank: bank,
    branch: branch,
    favored: branch.name,
    standard: true
  )

  representative = Representative.create!(
    partnership: Faker::Commerce.price(range: 1..10.0),
    name: Faker::Name.name,
    branch: branch
  )

  CurrentAccount.create!(
    bank: bank,
    representative: representative,
    favored: representative.name,
    standard: true
  )

  prescriber = Prescriber.create!(
    name: Faker::Name.name,
    council: "#{Faker::Name.first_name} - Conselho",
    secretary: "#{Faker::Name.first_name} - Secretaria",
    note: Faker::Lorem.sentence,
    class_council: rand(1..9),
    uf_council: Faker::Address.state_abbr,
    number_council: Array.new(6) { rand(1..9) }.join,
    partnership: Faker::Commerce.price(range: 1.0..10.0),
    discount_value: Faker::Commerce.price(range: 1.0..10.0),
    representative: representative
  )

  CurrentAccount.create!(
    bank: bank,
    prescriber: prescriber,
    favored: prescriber.name,
    standard: true
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
    prescriber: prescriber,
    representative: representative
  )

  monthly_report = MonthlyReport.create!(
    total_price: Faker::Commerce.price(range: 100.0..1000.0),
    partnership: Faker::Commerce.price(range: 10.0..100.0),
    discounts: Faker::Commerce.price(range: 1.0..10.0),
    report: Faker::Lorem.sentence,
    quantity: 1,
    accumulated: i.even?,
    envelope_number: i + 1,
    closing: closing,
    prescriber: prescriber,
    representative: representative
  )

  request = Request.create!(
    cdfil_id: Faker::Number.number(digits: 5),
    nrreq_id: Faker::Number.number(digits: 5),
    entry_date: Faker::Date.backward(days: 30),
    total_price: Faker::Commerce.price(range: 1000.0..10000.0),
    amount_received: Faker::Commerce.price(range: 150.0..5000.0),
    total_fees: Faker::Commerce.price(range: 1.0..10.0),
    total_discounts: Faker::Commerce.price(range: 50.0..200.0),
    repeat: i.even?,
    payment_date: Faker::Date.forward(days: 30),
    value_for_report: Faker::Commerce.price(range: 5.0..500.0),
    rg: Faker::IdNumber.valid,
    patient_name: Faker::Name.name,
    branch: branch,
    prescriber: prescriber,
    representative: representative,
    monthly_report: monthly_report
  )

  Discount.create!(
    price: Faker::Commerce.price(range: 1.0..10.0),
    description: Faker::Commerce.product_name,
    visible: true,
    branch: branch,
    prescriber: prescriber,
    monthly_report: monthly_report,
    request: request
  )
end

puts "FIM!"
