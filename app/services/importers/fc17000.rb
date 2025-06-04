module Importers
  class Fc17000
    def initialize(file_path)
      @file_path = file_path
    end

    def import!
      File.open(@file_path, "rb") do |file|
        csv_enum = CSV.new(file.read.encode("UTF-8", invalid: :replace, undef: :replace, replace: ""), col_sep: ",")
        csv_enum.each do |row|
          unless row[1] == "N/A" || row[0].nil?
            cdfil_id = row[0].to_s.strip
            nrreq_id = row[1].to_s.strip
            entry_date = row[2].to_s.strip
            total_fees = row[5].to_s.strip
            amount_received = row[6].to_s.strip
            total_price = row[3].to_f - total_fees.to_f
            total_discounts = row[4].to_f - total_fees

            Request.find_or_create_by(nrreq_id: nrreq_id) do |r|
              r.cdfil_id = cdfil_id
              r.total_price = total_price
              r.total_discounts = total_discounts
              r.total_fees = total_fees
              r.value_for_report = total_price
              r.amount_received = amount_received
              r.entry_date = entry_date
            end
          end
        end
      rescue CSV::MalformedCSVError => e
        puts "Erro ao processar linha: #{row.inspect} - #{e.message}"
      rescue => e
        puts "Erro inesperado: #{e.message}"
      end
    end
  end
end
