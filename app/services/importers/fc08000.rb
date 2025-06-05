module Importers
  class Fc08000
    def initialize(file_path)
      @file_path = file_path
    end

    def import!
      File.open(@file_path, "rb") do |file|
        csv_enum = CSV.new(file.read.encode("UTF-8", invalid: :replace, undef: :replace, replace: ""), col_sep: ",")
        csv_enum.each do |row|
          next if row.empty? || (row[0]&.strip == "N/A")

          number = row[0]&.strip
          name = row[1]&.strip
          district = row[2]&.strip
          optional_name = row[3]&.strip

          new_name = if name.present? && name != "." && name != "N/A"
            adjust_name(name)
          elsif optional_name == "N/A"
            optional_name
          else
            adjust_name(optional_name)
          end

          branch = Branch.search_global(district.capitalize).last

          Representative.find_or_create_by(number: number) do |representative|
            representative.name = new_name
            representative.branch = branch
          end
        end
      rescue CSV::MalformedCSVError => e
        puts "Erro ao processar linha: #{row.inspect} - #{e.message}"
      rescue => e
        puts "Erro inesperado: #{e.message}"
      end
    end

    def adjust_name(name_fun)
      name_fun = name_fun.downcase.tr("_", " ")
      parts = name_fun.split.map(&:capitalize)

      if parts.length > 1 && parts.last.length <= 1
        parts.pop
      end

      parts.join(" ")
    end
  end
end
