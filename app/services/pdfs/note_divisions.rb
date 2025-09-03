module Pdfs
  class NoteDivisions < BaseClosingPdf
    def generate_content
      header

      @representatives.each_with_index do |representative, index|
        move_down 25
        content(representative, @total_in_cash[representative.id])
        move_down 25
      end
    end

    def header
      table([
        [
          {content: "Divisão de Notas por Representante em"},
          {content: @current_closing.closing}
        ]
      ], cell_style: {borders: [], size: 12}, position: :center) do
        row(0).font_style = :bold
        [1, 3].each do |col|
          columns(col).text_color = "00008b"
        end
      end
    end

    def content(representative, total_in_cash)
      build_generic_table(
        title: representative.name.upcase,
        headers: ["Quantidade", "Notas", "Valor"],
        rows: total_in_cash.map { |item, cash| [cash || 0, item || "N/A", number_to_currency(cash * item || 0)] },
        footer: [["Total de Notas", "", "Total"], [total_in_cash.values.sum || 0, "", number_to_currency(total_in_cash.sum { |key, value| key * value } || 0)]],
        type: "notes"
      )
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
          row(5).font_style = :bold
        end
    end
  end
end
