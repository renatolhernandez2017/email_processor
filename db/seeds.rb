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

puts "FIM!"
