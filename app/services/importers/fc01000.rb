module Importers
  class Fc01000
    def initialize(file_path)
      @file_path = file_path
    end

    def import!
      seen_names = {}

      File.open(@file_path, "rb") do |file|
        csv_enum = CSV.new(
          file.read.encode("UTF-8", invalid: :replace, undef: :replace, replace: ""),
          col_sep: ","
        )

        csv_enum.each do |row|
          next if row.empty? || (row[1]&.strip == "N/A")

          name = row[1]&.strip
          branch_number = row[0]&.strip&.to_i
          current_account = row[2]&.strip

          normalized_name = name.upcase

          # Se já tiver filial com o nome e outro número de filial
          # ignorar duplicatas com o mesmo nome
          if seen_names.key?(normalized_name)
            next if seen_names[normalized_name] != branch_number
          else
            seen_names[normalized_name] = branch_number
          end

          branch = create_branch(normalized_name, branch_number)

          next if current_account == "N/A" || current_account.empty?

          @bank_name, @agency, @account = current_account.scan(/^(.+?)\s*[\-–]?\s*(?:AG(?:[ÊE]NCIA)?\.?\s*)?(\d+)\s*[\-–]?\s*C\/C\s*(\d+-\d+)/i).flatten

          next unless @bank_name && @agency && @account

          create_account_bank(branch)
        rescue CSV::MalformedCSVError => e
          puts "Erro ao processar linha: #{row.inspect} - #{e.message}"
        rescue => e
          puts "Erro inesperado: #{e.message}"
        end
      end
    end

    def create_branch(normalized_name, branch_number)
      formatted_name = normalized_name.split.map(&:capitalize).join(" ")

      Branch.find_or_create_by(branch_number: branch_number) do |b|
        b.name = formatted_name
      end
    end

    def create_account_bank(branch)
      Bank.where(name: @bank_name, agency_number: @agency, account_number: @account)
        .first_or_create do |bank|
          CurrentAccount.where(branch: branch, standard: true).update_all(standard: false)

          CurrentAccount.create!(
            favored: branch.name,
            standard: true,
            bank: bank,
            branch: branch
          )
        end
    end
  end
end
