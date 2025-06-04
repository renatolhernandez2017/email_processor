class UnificarArquivos
  def initialize(arquivo1, arquivo2, arquivo3, destino)
    @arquivo1 = arquivo1
    @arquivo2 = arquivo2
    @arquivo3 = arquivo3
    @destino = destino
  end

  def unificar_dados
    pessoas = Hash.new { |h, k| h[k] = {} }

    # Processa arquivo 1 (nome, data, status)
    CSV.foreach(@arquivo1, col_sep: ",") do |row|
      next if row[0].nil? || row[1].nil? # Ignora linhas sem ID

      id = row[1]
      pessoas[id].merge!(
        id_origem: row[0]&.strip,
        nrrqu: id&.strip,
        name: row[2]&.strip,
        entry_date: row[3]&.strip,
        status: row[4]&.strip
      )
    end

    # Processa arquivo 2 (valores financeiros)
    CSV.foreach(@arquivo2, col_sep: ",") do |row|
      next if row[0].nil? || row[1].nil? # Ignora linhas sem ID

      id = row[1]
      pessoas[id].merge!(
        total: row[3]&.strip,
        discount: row[4]&.strip,
        fees: row[5]&.strip,
        received: row[6]&.strip
      )
    end

    # Processa arquivo 3 (valores finais)
    CSV.foreach(@arquivo3, col_sep: ",") do |row|
      next if row[0].nil? || row[1].nil? # Ignora linhas sem ID

      id = row[1]
      pessoas[id].merge!(
        payment_date: row[2]&.strip,
        total_received: row[3]&.strip
      )
    end

    # Gera novo CSV
    CSV.open(@destino, "wb", col_sep: ",") do |csv|
      csv << [
        "ID", "Nome", "Data de Entrada", "Status",
        "Total", "Desconto", "Taxas", "Recebido",
        "Data de Pagamento", "Total Recebido"
      ]

      pessoas.each do |id, dados|
        csv << [
          id,
          dados[:name],
          dados[:entry_date],
          dados[:status],
          dados[:total],
          dados[:discount],
          dados[:fees],
          dados[:received],
          dados[:payment_date],
          dados[:total_received]
        ]
      end
    end

    puts "Arquivo unificado gerado em: #{@destino}"
  end
end
