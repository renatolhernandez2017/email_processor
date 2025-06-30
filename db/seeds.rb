puts "apagando dados antigos..."
User.destroy_all
Closing.destroy_all
Address.destroy_all
Prescriber.destroy_all
Representative.destroy_all
Branch.destroy_all
CurrentAccount.destroy_all
Bank.destroy_all
MonthlyReport.destroy_all
Request.destroy_all

puts "Criando Users admin"
User.create!(name: "renato", email: "renatolhernandez@gmail.com", password: "120711", role: "admin")
User.create!(name: "luiz", email: "luizunipharmus@yahoo.com.br", password: "ro050604", role: "admin")
puts "Fim Users admin"

start_date = "29-07-2023".to_date
end_date = "29-08-2023".to_date

puts "Criando Fechamento"
Closing.create!(
  start_date: start_date,
  end_date: end_date,
  closing: "#{end_date.strftime("%b")}/#{end_date.strftime("%y")}",
  last_envelope: 1,
  active: true
)
puts "Fim Fechamento"

puts "Criando Filiais"
load Rails.root.join("db/seeds/branches.rb")
puts "Fim Filiais"

puts "Criando Representantes"
load Rails.root.join("db/seeds/representatives.rb")
puts "Fim Representantes"

puts "Criando Prescritores"
load Rails.root.join("db/seeds/prescribers.rb")
puts "Fim Prescritores"

puts "Atualizar Prescritores"
load Rails.root.join("db/seeds/prescribers_update.rb")
puts "Fim Atualizar Prescritores"

puts "Acabou!"
