module Importers
  class Fc12100
    def initialize(file_path)
      @file_path = file_path
    end

    def import!
      group_by_nrreq_id

      # File.open(@file_path, "rb") do |file|
      #   csv_enum = CSV.new(file.read.encode("UTF-8", invalid: :replace, undef: :replace, replace: ""), col_sep: ",")
      #   csv_enum.each do |row|
      #     unless row[1] == "N/A" || row[0].nil?
      #       Request.create!(
      #         cdfil_id: row[0].to_s.strip,
      #         nrreq_id: row[1].to_s.strip,
      #         patient_name: row[2].to_s.gsub(/[,"';\\\/]/, " "),
      #         entry_date: row[3],
      #         repeat: row[4] == "S"
      #       )
      #     end
      #   end
      # rescue CSV::MalformedCSVError => e
      #   puts "Erro ao processar linha: #{row.inspect} - #{e.message}"
      # rescue => e
      #   puts "Erro inesperado: #{e.message}"
      # end
    end

    def group_by_nrreq_id
      output_path = "tmp/resultado_agrupado.csv"
      group = Hash.new { |h, k| h[k] = {count: 0, row: nil} }

      File.open(@file_path, "rb") do |file|
        csv_enum = CSV.new(
          file.read.encode("UTF-8", invalid: :replace, undef: :replace, replace: ""),
          col_sep: ","
        )

        csv_enum.each do |row|
          next if row.nil? || row.empty?

          name = row[2]
          group[name][:count] += 1
          group[name][:row] ||= row # salva apenas a primeira ocorrência
        end
      end

      # Grava no CSV final
      CSV.open(output_path, "wb", col_sep: ",") do |csv|
        group.each do |_, data|
          csv << data[:row] + [data[:count]]
        end
      end
    end
  end
end
