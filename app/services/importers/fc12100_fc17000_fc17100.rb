module Importers
  class Fc12100Fc17000Fc17100
    def initialize(file_path)
      @file_path = file_path
    end

    def import!
      File.open(@file_path, "rb") do |file|
        csv_enum = CSV.new(file.read.encode("UTF-8", invalid: :replace, undef: :replace, replace: ""), col_sep: ",")
        csv_enum.each do |row|
          next if row.empty? || (row[0]&.strip == "N/A")

          @cdfil_id = row[0]&.strip
          @nrreq_id = row[1]&.strip
          crm = row[2]&.strip
          @patient_name = row[3]&.gsub(/[,"';\\\/]/, " ")
          @entry_date = row[4]&.strip
          @repeat = row[5]&.strip
          @rg = row[6]&.strip
          branch_number = row[7]&.strip&.to_i
          representative_number = row[8]&.strip&.to_i
          @total_price = row[9]&.strip&.to_f - row[11]&.strip&.to_f
          @total_discounts = row[10]&.strip&.to_f
          @total_fees = row[11]&.strip&.to_f
          @payment_date = row[12]&.strip
          @amount_received = row[13]&.strip&.to_f

          prescriber = Prescriber.find_by(crm: crm)
          branch = Branch.find_by(branch_number: branch_number)
          representative = Representative.find_by(representative_number: representative_number)

          create_request(prescriber, branch, representative)
        end
      rescue CSV::MalformedCSVError => e
        puts "Erro ao processar linha: #{row.inspect} - #{e.message}"
      rescue => e
        puts "Erro inesperado: #{e.message}"
      end
    end

    def create_request(prescriber, branch, representative)
      Request.create!(
        cdfil_id: @cdfil_id,
        nrreq_id: @nrreq_id,
        patient_name: @patient_name,
        entry_date: @entry_date,
        repeat: @repeat == "S",
        rg: @rg,
        total_fees: @total_fees,
        amount_received: @amount_received,
        total_price: @total_price,
        total_discounts: @total_discounts,
        payment_date: @payment_date,
        value_for_report: @total_price,
        prescriber: prescriber,
        branch: branch,
        representative: representative
      )
    end
  end
end
