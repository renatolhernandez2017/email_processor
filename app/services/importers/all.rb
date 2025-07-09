module Importers
  class All
    def initialize(file_path)
      @file_path = file_path
    end

    def import!
      File.open(@file_path, "rb") do |file|
        csv_enum = CSV.new(file.read.encode("UTF-8", invalid: :replace, undef: :replace, replace: ""), col_sep: ",")
        csv_enum.each do |row|
          next if row.empty? || (row[0]&.strip == "N/A")

          branch_number = row[0]&.strip
          @nrreq_id = row[1]&.strip
          @patient_name = row[2]&.strip
          @entry_date = row[3]&.strip
          @repeat = row[4]&.strip
          @total_price = row[5]&.strip.to_f - row[7]&.strip&.to_f
          @total_discounts = row[6]&.strip.to_f
          @total_fees = row[7]&.strip&.to_f
          @payment_date = row[8]&.strip
          @amount_received = row[9]&.strip.to_f - @total_discounts
          @class_council = row[10]&.strip
          @uf_council = row[11]&.strip
          @number_council = row[12]&.strip
          @prescriber_name = row[13]&.strip
          @note = row[14]&.strip
          representative_number = row[15]&.strip

          @representative = Representative.find_by(number: representative_number)
          @prescriber = create_prescriber(representative_number)

          create_address(row)
          create_request(branch_number)
        end
      end
    end

    def create_prescriber(representative_number)
      prescriber = Prescriber.find_or_create_by(class_council: @class_council, uf_council: @uf_council, number_council: @number_council)

      prescriber.update!(
        name: @prescriber_name,
        note: @note,
        representative_number: representative_number,
        representative: @representative
      )

      prescriber
    end

    def create_address(row)
      street = row[16]&.strip
      number = row[17]&.strip
      complement = row[18]&.strip
      district = row[19]&.strip
      zip_code = row[20]&.strip
      city = row[21]&.strip
      uf = row[22]&.strip
      cellphone = "#{row[23]&.strip} #{row[24]&.strip}".strip
      phone = "#{row[25]&.strip} #{row[26]&.strip}".strip

      Address.find_or_create_by(street: street, number: number, zip_code: zip_code) do |address|
        address.district = district
        address.complement = complement
        address.city = city
        address.uf = uf
        address.phone = phone
        address.cellphone = cellphone
        address.prescriber = @prescriber
      end
    end

    def create_request(branch_number)
      branch = Branch.find_by(branch_number: branch_number)
      total_price = branch.present? ? (@total_price * ((100.0 - branch.discount_request) / 100.0)) : @total_price

      Request.create!(
        cdfil_id: branch_number,
        nrreq_id: @nrreq_id,
        patient_name: @patient_name,
        entry_date: @entry_date,
        repeat: @repeat == "S",
        total_fees: @total_fees,
        amount_received: @amount_received,
        total_price: total_price,
        total_discounts: @total_discounts,
        payment_date: @payment_date,
        value_for_report: total_price,
        prescriber: @prescriber,
        branch: branch,
        representative: @representative
      )
    end
  end
end
