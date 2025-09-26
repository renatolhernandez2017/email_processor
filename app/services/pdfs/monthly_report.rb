module Pdfs
  class MonthlyReport < BaseRepresentativePdf
    def generate_content
      @representatives.each_with_index do |representative, index|
        start_new_page if index > 0

        header(representative)
        move_down 25

        table_monthly_reports(@prescribers[representative.id], @totals[representative.id])
        move_down 25

        table_by_bank(@totals_by_bank[representative.id], @totals_from_banks[representative.id])
        move_down 20

        table_by_store(@totals_by_store[representative.id], @totals_from_stores[representative.id])
        move_down 20

        table_by_notes(@total_in_cash[representative.id])
        move_down 20
      end
    end

    def header(representative)
      table([
        [
          {content: "Resumo de"},
          {content: representative.name.upcase},
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

    def table_monthly_reports(prescribers, totals)
      headers = [
        "Id", "Prescritor", "Qt.", "Total", "Parceria",
        "Desc.", "Valor Disp.", "Tipo", "Envelope"
      ]

      rows = prescribers.map do |prescriber|
        [
          prescriber.id,
          prescriber.name,
          prescriber.quantity,
          number_to_currency(prescriber.price),
          number_to_currency(prescriber.partnership),
          number_to_currency(prescriber.discounts),
          number_to_currency(prescriber.available_value),
          prescriber.kind,
          prescriber.envelope_number
        ]
      end

      footer = build_monthly_reports_footer(totals)
      data = build_table_data(headers: headers, rows: rows, footer: footer)

      render_table(data, "reports")
    end

    def table_by_bank(totals_by_bank, totals_from_banks)
      build_generic_table(
        title: "Total por Banco",
        headers: ["Quantidade", "Banco", "Valor"],
        rows: totals_by_bank.map { |bank| [bank.count, bank.bank_name, number_to_currency(bank.total)] },
        footer: [["Total de Bancos", "", "Total"], [totals_from_banks[:total_count], "", number_to_currency(totals_from_banks[:total_price])]],
        type: "banks"
      )
    end

    def table_by_store(totals_by_store, totals_from_stores)
      build_generic_table(
        title: "Total por Loja",
        headers: ["Quantidade", "Loja", "Valor"],
        rows: totals_by_store.map { |store| [store.count, store.branch_name, number_to_currency(store.total)] },
        footer: [["Total de Lojas", "", "Total"], [totals_from_stores[:total_count], "", number_to_currency(totals_from_stores[:total_price])]],
        type: "stores"
      )
    end

    def table_by_notes(total_in_cash)
      build_generic_table(
        title: "Divisão de Notas",
        headers: ["Quantidade", "Notas", "Valor"],
        rows: total_in_cash.map { |item, cash| [cash || 0, item, number_to_currency(cash * item || 0)] },
        footer: [["Total de Notas", "", "Total"], [total_in_cash.values.sum || 0, "", number_to_currency(total_in_cash.sum { |key, value| key * value } || 0)]],
        type: "notes"
      )
    end

    def build_monthly_reports_footer(totals)
      [
        ["Quant.", "", "", "", "", "", "", "", ""],
        [
          totals[:count],
          "Total Geral",
          totals[:quantity],
          number_to_currency(totals[:price]),
          number_to_currency(totals[:partnership]),
          number_to_currency(totals[:discounts]),
          number_to_currency(totals[:available_value]),
          "", ""
        ],
        [
          totals[:accumulated][:count],
          "Acumulados",
          totals[:accumulated][:quantity],
          number_to_currency(totals[:accumulated][:price]),
          number_to_currency(totals[:accumulated][:partnership]),
          number_to_currency(totals[:accumulated][:discounts]),
          number_to_currency(totals[:accumulated][:available_value]),
          "", ""
        ],
        [
          totals[:real_sale][:count],
          "Venda Real",
          totals[:real_sale][:quantity],
          number_to_currency(totals[:real_sale][:price]),
          number_to_currency(totals[:real_sale][:partnership]),
          number_to_currency(totals[:real_sale][:discounts]),
          number_to_currency(totals[:real_sale][:available_value]),
          "", ""
        ]
      ]
    end

    def build_table_data(headers:, rows:, footer: [])
      data = [headers]
      data.concat(rows)
      data << Array.new(headers.size, "")
      data.concat(footer)
      data
    end

    def build_generic_table(title:, headers:, rows:, footer:, type:)
      text title, size: 12, style: :bold, color: "00008b"
      data = build_table_data(headers: headers, rows: rows, footer: footer)
      render_table(data, type)
    end

    def render_table(data, type)
      table(data.compact,
        header: true,
        row_colors: ["F0F0F0", "FFFFFF"],
        width: bounds.width,
        cell_style: {borders: [:bottom], border_width: 0.5, size: 6.5}) do
          row(0).font_style = :bold

          case type
          when "reports"
            if data.size <= 7
              cells[1, 1].text_color = "00008b"
              row(3).font_style = :bold
            else
              (1...data.size - 5).each { |i| cells[i, 1].text_color = "00008b" }
              (4...data.size - 3).each { |i| row(i).font_style = :bold }
              (4...data.size).each { |row_index| cells[row_index, 1].font_style = :bold }
            end
          when "banks", "stores", "notes"
            if data.size <= 5
              row(data.size - 2).font_style = :bold
            else
              (6...data.size - 1).each { |row_index| row(row_index).font_style = :bold }
            end
          end
        end
    end
  end
end
