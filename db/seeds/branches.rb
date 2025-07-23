File.open("#{Rails.root}/public/branches.csv", "rb") do |file|
  csv_enum = CSV.new(
    file.read.encode("UTF-8", invalid: :replace, undef: :replace, replace: ""),
    col_sep: ","
  )

  csv_enum.each do |row|
    branch_number = row[0]&.strip.to_i
    name = row[1]&.strip&.upcase&.split&.map(&:capitalize)&.join(" ")
    bank_name = row[2]&.strip
    agency_number = row[3]&.strip
    account_number = row[4]&.strip
    discount_request = row[5]&.strip

    branch = Branch.create!(name: name, branch_number: branch_number, discount_request: discount_request)
    bank = Bank.create!(name: bank_name, agency_number: agency_number, account_number: account_number)

    CurrentAccount.create!(favored: branch.name, standard: true, bank: bank, branch: branch)
  end
end
