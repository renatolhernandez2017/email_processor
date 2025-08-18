module Pdfs
  class UnaccumulatedAddresses < BaseRepresentativePdf
    def generate_content
      @representatives.each_with_index do |representative, index|
        start_new_page unless index == 0
        @representative = representative

        header
        move_down 5

        @prescribers[@representative.id].each do |prescriber|
          @prescriber = prescriber

          content
        end
      end
    end

    private

    def header
      table([
        [
          {content: "Relatório de Endereços de"},
          {content: @representative.name.upcase},
          {content: "em"},
          {content: @current_closing.closing}
        ]
      ], cell_style: {borders: [], size: 12}, position: :center) do
        row(0).font_style = :bold
        [1, 3].each { |col_index| cells[0, col_index].text_color = "00008b" }
      end
    end

    def content
      headers = ["Envelope", "Informações", "Quant.", "Valor Disp."]

      rows = [
        [
          @prescriber.envelope_number,
          [
            "<b>Nome:</b> <color rgb='00008b'>#{@prescriber.name}</color>",
            "<b>Endereço:</b> #{@prescriber&.full_address}",
            "<b>Fones:</b> #{@prescriber&.full_contact}",
            "<b>Contatos:</b> #{@prescriber.secretary}",
            "<b>OBS:</b> #{truncate(@prescriber.note, length: 50)}"
          ].compact.join("\n"),
          @prescriber.quantity,
          number_to_currency(@prescriber.available_value)
        ]
      ]

      data = build_table_data(headers: headers, rows: rows)

      render_table(data)
      move_down 10
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
        cell_style: {borders: [:bottom], border_width: 0.5, size: 8.5, inline_format: true}) do
          row(0).font_style = :bold
          [0, 2, 3].each do |col|
            columns(col).align = :center
            columns(col).valign = :center
          end
        end
    end
  end
end
