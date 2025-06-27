File.open("#{Rails.root}/public/prescribers.csv", "rb") do |file|
  csv_enum = CSV.new(
    file.read.encode("UTF-8", invalid: :replace, undef: :replace, replace: ""),
    col_sep: ","
  )

  csv_enum.each do |row|
    class_council = row[0]&.strip
    uf_council = row[1]&.strip
    number_council = row[2]&.strip
    prescriber_name = row[3]&.strip
    note = row[4]&.strip
    representative_number = row[5]&.strip
    street = row[6]&.strip
    number = row[7]&.strip
    complement = row[8]&.strip
    district = row[9]&.strip
    zip_code = row[10]&.strip
    city = row[11]&.strip
    uf = row[12]&.strip
    cellphone = "#{row[13]&.strip} #{row[14]&.strip}".strip
    phone = "#{row[15]&.strip} #{row[16]&.strip}".strip

    representative = Representative.find_by(number: representative_number)

    prescriber =  Prescriber.create!(
      class_council: class_council, uf_council: uf_council, number_council: number_council,
      name: prescriber_name, note: note, representative_number: representative_number,
      representative: representative
    )

    Address.create!(
      street: street, number: number, zip_code: zip_code, district: district, complement: complement,
      city: city, uf: uf, phone: phone, cellphone: cellphone, prescriber: prescriber
    )
  end
end
