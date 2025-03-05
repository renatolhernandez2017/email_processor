puts "apagando dados antigos..."
User.destroy_all
Closing.destroy_all

puts "Criando user Admin"
User.create!(name: "Renato Hernandez", email: "renatolhernandez@gmail.com", password: "123123", role: "admin")

puts "Criando Fechamento e relatórios"
date = Date.today

15.times do |i|
  start_date = (date << (i + 1)).next_day - 1
  end_date = (date << i).next_day - 1

  Closing.create!(
    start_date: start_date,
    end_date: end_date,
    closing: "#{end_date.strftime("%b")}/#{end_date.strftime("%y")}",
    last_envelope: i + 1
  )
end

puts "Criando Representantes"
kind = ["prescriber", "representative"]

15.times do |i|
  Person.create!(
    name: Faker::Name.name,
    cpf: Faker::IDNumber.brazilian_citizen_number,
    birthdate: Faker::Date.birthday(min_age: 18, max_age: 65),
    kind: kind.sample,
    cnpj: Faker::Company.brazilian_company_number,
    rg: Faker::IDNumber.brazilian_id,
    representative_number: i + 1,
    class_concil: Faker::Educator.course_name,
    uf_concil: Faker::Address.state_abbr,
    number_concil: Faker::IDNumber.valid
  )
end

puts "FIM!"
