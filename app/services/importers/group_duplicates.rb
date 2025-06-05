module Importers
  class GroupDuplicates
    def initialize(file_path)
      @file_path = file_path
    end

    def import!
      grouped_data = {}

      File.open(@file_path, "rb") do |file|
        csv_enum = CSV.new(file.read.encode("UTF-8", invalid: :replace, undef: :replace, replace: ""), col_sep: ",")
        csv_enum.each do |row|
          cdfil, nrrqu, nrcrm, nomepa, dtentr, indrepet,
          vrrqu, vrdsc, vrtxa, vrrcb, dtpag, soma_rcb_taxa = row

          next if row[0].nil?

          # Salva apenas o primeiro registro de cada NRRQU
          grouped_data[nrrqu] ||= [
            cdfil, nrrqu, nrcrm, nomepa, dtentr, indrepet,
            vrrqu, vrdsc, vrtxa, vrrcb, dtpag, soma_rcb_taxa
          ]
        end

        export_csv(grouped_data)
      end
    end

    private

    def export_csv(data)
      output_path = "#{Rails.root}/tmp/group_duplicates.csv"

      CSV.open(output_path, 'w') do |csv|
        # Escreve linhas agrupadas
        data.each_value do |row|
          csv << row
        end
      end

      puts "Arquivo exportado com sucesso para: #{output_path}"
    end
  end
end
