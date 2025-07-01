module Pdfs
  class PatientListing < BaseMonthlyPdf
    def generate_content
      @representatives.each do |representative|
        first_page = true
        monthly_reports = representative.set_monthly_reports(@current_closing.id)

        monthly_reports.each do |reports|
          if !first_page && reports[:situation].present?
            start_new_page
          end

          first_page = false
          @representative = representative

          header
          move_down 10

          @monthly_reports = reports
          content
        end
      end
    end

    private

    def header
      table([
        [
          {content: "Listagem de Pacientes de"},
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
      @monthly_reports[:monthly_reports].each do |monthly_report|
        move_down 10
        table([
          [
            { content: "Prescritor:", font_style: :bold },
            { content: monthly_report.prescriber.name },
            { content: "Situação:", font_style: :bold },
            { content: @monthly_reports[:situation] },
            { content: "Envelope:", font_style: :bold },
            { content: @monthly_reports[:envelope_number] }
          ]
        ], cell_style: { borders: [], size: 10 }, position: :center) do
          [1, 3, 5].each { |i| cells[0, i].text_color = "00008b" }
        end
        move_down 20

        headers = [
          "Pacientes", "Repetida", "Data de Entrada",
          "Data de Pagamento", "Valor Recebido", "Filial"
        ]

        rows = monthly_report.requests.map do |request|
          [
            request&.patient_name || "Sem Nome",
            request.repeat ? "-R" : "",
            request.entry_date.strftime("%d/%m/%y"),
            request.set_payment_date(request),
            request.set_price(request),
            request&.branch&.name || "Sem Filial"
          ]
        end

        footer = [
          ["Quantidade", "", "", "", "", "Valor Disponível"],
          [
            monthly_report.quantity,
            "", "", "", "",
            number_to_currency(monthly_report.available_value)
          ]
        ]

        data = build_table_data(headers: headers, rows: rows, footer: footer)
        render_table(data)

        move_down 20
      end
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
