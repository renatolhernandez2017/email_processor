module Pdfs
  class SummaryPatientListing < BaseMonthlyPdf
    def generate_content
      @representatives.each_with_index do |representative, index|
        start_new_page unless index == 0

        @representative = representative
        header
        move_down 10

        @prescribers[@representative.id].each do |prescriber|
          if prescriber.requests.present? && prescriber.envelope_number.to_s != "000000"
            @prescriber = prescriber
            content

            stroke_color "00008b"
            line_width 0.5
            stroke_horizontal_rule
            stroke_color "00008b"

            move_down 30
          end
        end
      end
    end

    private

    def header
      table([
        [
          {content: "Representante: "},
          {content: @representative.name.upcase},
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
      move_down 10
      table([
        [
          {content: "Prescritor:", font_style: :bold},
          {content: @prescriber.name},
          {content: "Situação:", font_style: :bold},
          {content: @prescriber.situation},
          {content: "Envelope:", font_style: :bold},
          {content: @prescriber.envelope_number}
        ]
      ], cell_style: {borders: [], size: 10}, position: :center) do
        [1, 3].each { |i| cells[0, i].text_color = "00008b" }
      end
      move_down 20

      headers = ["Quantidade", "", "", "Valor Disponível"]

      rows = [
        [
          @prescriber.quantity,
          "", "",
          number_to_currency(@prescriber.available_value)
        ]
      ]

      data = build_table_data(headers: headers, rows: rows)

      render_table(data)
      move_down 20
    end

    def build_table_data(headers:, rows:)
      data = [headers]
      data.concat(rows)
      data
    end

    def render_table(data)
      table(data.compact,
        header: true,
        row_colors: ["F0F0F0", "FFFFFF"],
        width: bounds.width,
        cell_style: {borders: [:bottom], border_width: 0.5, size: 8}) do
          row(0).font_style = :bold
        end
    end
  end
end
