module Importers
  class Fc04000
    def initialize(file_path)
      @file_path = file_path
    end

    def import!
      File.open(@file_path, "rb") do |file|
        csv_enum = CSV.new(file.read.encode("UTF-8", invalid: :replace, undef: :replace, replace: ""), col_sep: ",")
        csv_enum.each do |row|
          next if row.empty? || (row[0]&.strip == "N/A")

          class_council = row[0]&.strip
          @uf_council = row[1]&.strip
          @number_council = row[2]&.strip
          @prescriber_name = row[3]&.strip
          @note = row[4]&.strip
          representative_number = row[5]&.strip&.to_i

          prescriber = create_prescriber(representative_number)

          create_address(row, prescriber)
        end
      rescue CSV::MalformedCSVError => e
        puts "Erro ao processar linha: #{row.inspect} - #{e.message}"
      rescue => e
        puts "Erro inesperado: #{e.message}"
      end
    end

    def create_prescriber(representative_number)
      representative = Representative.find_by(number: representative_number) if representative_number != "N/A"

      Prescriber.find_or_create_by(crm: @number_council) do |prescriber|
        prescriber.name = @prescriber_name
        prescriber.note = @note
        prescriber.class_council = @class_council
        prescriber.number_council = @number_council
        prescriber.uf_council = @uf_council
        prescriber.crm = @number_council
        prescriber.representative_number = representative_number
        prescriber.representative = representative if representative.present?
      end
    end

    def create_address(row, prescriber)
      street = row[6]&.strip
      number = row[7]&.strip
      complement = row[8]&.strip
      district = row[9]&.strip
      zip_code = row[10]&.strip
      city = row[11]&.strip
      uf = row[12]&.strip
      cellphone = row[13]&.strip + " " + row[14]&.strip
      phone = row[15]&.strip + " " + row[16]&.strip
      fax = row[18]&.strip

      Address.create!(
        street: street,
        district: district,
        number: number,
        complement: complement,
        city: city,
        uf: uf,
        zip_code: zip_code,
        phone: phone,
        cellphone: cellphone,
        fax: fax,
        prescriber: prescriber
      )
    end
  end
end
