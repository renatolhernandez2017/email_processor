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
          next if row[0].nil?

          # indices dos campos de agrupamento:
          key = [row[1], row[11], row[12], row[13]].join("-")

          # Salva apenas o primeiro registro único por chave
          grouped_data[key] ||= row
        end

        export_csv(grouped_data)
      end
    end

    private

    def export_csv(data)
      output_path = "#{Rails.root}/tmp/group_duplicates.csv"

      CSV.open(output_path, "w") do |csv|
        data.each_value do |row|
          csv << row.map { |cell| cell.to_s.strip }.join(",").gsub(/,{2,}/, ",").split(",")
        end
      end

      puts "Arquivo exportado com sucesso para: #{output_path}"
    end
  end
end
