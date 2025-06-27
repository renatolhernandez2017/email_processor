File.open("#{Rails.root}/public/prescribers_update.csv", "rb") do |file|
  csv_enum = CSV.new(
    file.read.encode("UTF-8", invalid: :replace, undef: :replace, replace: ""),
    col_sep: ","
  )

  csv_enum.each do |row|
    class_council = row[0]&.strip
    uf_council = row[1]&.strip
    number_council = row[2]&.strip
    partnership = row[4]&.strip
    repetitions = row[5]&.strip
    percentage_discount = row[6]&.strip
    consider_discount_of_up_to = row[7]&.strip
    bank_name = row[8]&.strip
    agency_number = row[9]&.strip
    account_number = row[10]&.strip
    favored = row[11]&.strip

    prescriber = Prescriber.find_by(class_council: class_council, uf_council: uf_council, number_council: number_council)

    if prescriber.present?
      prescriber.update(
        partnership: partnership,
        repetitions: repetitions,
        percentage_discount: percentage_discount,
        consider_discount_of_up_to: consider_discount_of_up_to
      )

      unless bank_name == "N/A"
        new_favored = favored == "N/A" ? prescriber.name : favored

        bank = Bank.create!(
          name: bank_name, agency_number: agency_number, account_number: account_number
        )

        CurrentAccount.create!(
          bank_id: bank.id, prescriber_id: prescriber.id, favored: new_favored, standard: true
        )
      end
    end
  end
end
