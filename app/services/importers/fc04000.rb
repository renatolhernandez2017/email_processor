module Importers
  class Fc04000
    def initialize(file_path)
      @file_path = file_path
    end

    def import!
      File.open(@file_path, "rb") do |file|
        csv_enum = CSV.new(file.read.encode("UTF-8", invalid: :replace, undef: :replace, replace: ""), col_sep: ",")
        csv_enum.each do |row|
          class_council = row[0].to_s.strip

          next if class_council == "N/A" || class_council.empty?

          @uf_council = row[1].to_s.strip
          @number_council = row[2].to_s.strip
          @prescriber_name = row[3].to_s.strip
          @note = row[4].to_s.strip
          representative_number = row[5].to_s.strip

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
      representative = Representative.find_by(number: representative_number.to_i) if representative_number != "N/A"

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
      street = row[6].to_s.strip
      number = row[7].to_s.strip
      complement = row[8].to_s.strip
      district = row[9].to_s.strip
      zip_code = row[10].to_s.strip
      city = row[11].to_s.strip
      uf = row[12].to_s.strip
      cellphone = row[13].to_s.strip + " " + row[14].to_s.strip
      phone = row[15].to_s.strip + " " + row[16].to_s.strip
      fax = row[18].to_s.strip

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
