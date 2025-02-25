puts "apagando dados antigos..."
User.destroy_all

puts "Criando user Admin"
User.create!(name: "Renato Hernandez", email: "renatolhernandez@gmail.com", password: "123123", role: "admin")

puts "FIM!"
