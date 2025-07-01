module Pdfs
  class SummaryPatientListing < BaseMonthlyPdf
    include Prawn::View
    include ActionView::Helpers::NumberHelper

    def generate_content
      @representatives.each_with_index do |representative, index|
        start_new_page unless index == 0

        @representative = representative
        header
        move_down 10

        monthly_reports = representative.set_monthly_reports(@current_closing.id)

        monthly_reports.each do |reports|
          @monthly_reports = reports
          content

          stroke_color "00008b"
          line_width 0.5
          stroke_horizontal_rule
          stroke_color "00008b"

          move_down 30
        end
      end
    end

    private

    def header
      table([
        [
          {content: "Listagem Resumida de Pacientes de"},
          {content: @representative.name.upcase},
          {content: "em"},
          {content: @closing.to_s}
        ]
      ], cell_style: {borders: [], size: 12}, position: :center) do
        row(0).font_style = :bold
        [1, 3].each do |col|
          columns(col).text_color = "00008b"
        end
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

        headers = ["Quantidade", "", "", "Valor Disponível"]

        rows = [
          [
            @monthly_reports[:quantity],
            "", "",
            number_to_currency(@monthly_reports[:available_value])
          ]
        ]

        data = build_table_data(headers: headers, rows: rows)

        render_table(data)
        move_down 20
      end
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
