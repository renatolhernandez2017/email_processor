module Importers
  class Fc17100
    def initialize(file_path)
      @file_path = file_path
    end

    def import!
      File.open(@file_path, "rb") do |file|
        csv_enum = CSV.new(file.read.encode("UTF-8", invalid: :replace, undef: :replace, replace: ""), col_sep: ",")
        csv_enum.each do |row|
          next if row[1].to_s.strip.empty?

          cdfil_id = row[0].to_s.rjust(3)
          nrreq_id = row[1].to_s.rjust(6)
          payment_date = row[2]

          Request.find_or_create_by(nrreq_id: nrreq_id) do |r|
            r.cdfil_id = cdfil_id
            r.payment_date = payment_date
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
