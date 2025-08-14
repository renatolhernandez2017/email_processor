module Pdfs
  class DepositsInBanks < BaseClosingPdf
    def generate_content
      @banks.each_with_index do |(bank_name, current_accounts), index|
        start_new_page unless index == 0
        @bank_name = bank_name
        @current_accounts = current_accounts

        header
        content
      end
    end

    def header
      table([
        [
          {content: "Depósitos no"},
          {content: @bank_name.upcase},
          {content: "em"},
          {content: @current_closing.closing}
        ]
      ], cell_style: {borders: [], size: 12}, position: :center) do
        row(0).font_style = :bold
        [1, 3].each do |col|
          columns(col).text_color = "00008b"
        end
      end
    end

    def content
      headers = [
        "Representante ID", "Agência", "Conta",
        "Favorecido", "Valor Disponivel", "Representante"
      ]

      rows = @current_accounts.map do |current_account|
        [
          current_account.representative_id,
          current_account.agency_number,
          current_account.account_number,
          current_account.favored,
          number_to_currency(current_account.available_value),
          current_account.representative_name || "Unipharmus"
        ]
      end

      footer = [
        [
          "Total",
          "", "", "",
          number_to_currency(@current_accounts.sum(&:available_value)),
          ""
        ]
      ]

      data = build_table_data(headers: headers, rows: rows, footer: footer)
      render_table(data)
    end

    def build_table_data(headers:, rows:, footer: [])
      data = [headers]
      data.concat(rows)
      data << Array.new(headers.size, "")
      data.concat(footer)
      data
    end

    def render_table(data)
      table(data.compact,
        header: true,
        row_colors: ["F0F0F0", "FFFFFF"],
        width: bounds.width,
        cell_style: {borders: [:bottom], border_width: 0.5, size: 7.5}) do
          (1...data.size - 3).each { |i|
            cells[i, 0].text_color = "00008b"
            cells[i, 3].text_color = "00008b"
          }

          [0, data.size - 2].each { |i| row(i).font_style = :bold }
        end
    end
  end
end
