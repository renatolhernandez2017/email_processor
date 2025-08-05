module Pdfs
  class PatientListing < BaseMonthlyPdf
    def generate_content
      @representatives.each_with_index do |representative, index|
        start_new_page unless index.zero?
        @representative = representative
        first_page = true

        @prescribers[@representative.id].each do |prescriber|
          if prescriber.requests.present? && prescriber.envelope_number.to_s != "000000"
            if !first_page && prescriber.situation.present?
              start_new_page
            end

            @prescriber = prescriber
            first_page = false

            header
            move_down 10

            @requests = @prescriber.requests
            content
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
          {content: @closing.to_s}
        ]
      ], cell_style: {borders: [], size: 12}, position: :center) do
        row(0).font_style = :bold
        [1, 3].each { |col_index| cells[0, col_index].text_color = "00008b" }
      end
    end

    def content
      move_down 20
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

      headers = [
        "Pacientes", "Repetida", "Data de Entrada",
        "Data de Pagamento", "Valor", "Filial"
      ]

      rows = @requests.map do |request|
        [
          request.patient_name || "Sem Nome",
          request.repeat ? "-R" : "",
          request.entry_date.strftime("%d/%m/%y"),
          set_payment_date(request),
          set_price(request),
          request.branch&.name || "Sem Filial"
        ]
      end

      footer = [
        ["Quantidade", "", "", "", "", "Valor Disponível"],
        [
          @prescriber.quantity,
          "", "", "", "",
          number_to_currency(@prescriber.available_value)
        ]
      ]

      data = build_table_data(headers: headers, rows: rows, footer: footer)
      render_table(data)

      move_down 20
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
        cell_style: {borders: [:bottom], border_width: 0.5, size: 8}) do
          (1...data.size - 3).each { |i| cells[i, 0].text_color = "00008b" }

          if data.size <= 5
            [0, 3].each { |i| row(i).font_style = :bold }
          else
            [0, data.size - 2].each { |i| row(i).font_style = :bold }
          end
        end
    end
  end
end
