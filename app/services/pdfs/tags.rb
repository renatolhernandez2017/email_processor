module Pdfs
  class Tags < BaseMonthlyPdf
    def generate_content
      @representatives.each_with_index do |representative, index|
        start_new_page unless index == 0
        @representative = representative
        @monthly_reports = @representative.load_monthly_reports(@current_closing.id, [{prescriber: {current_accounts: :bank}}])

        header
        move_down 5

        @monthly_reports.each do |monthly_report|
          @monthly_report = monthly_report

          other_header
          content
        end
      end
    end

    private

    def header
      table([
        [
          {content: "Etiquetas de"},
          {content: @representative.name.upcase + " -"},
          {content: @current_closing.end_date.strftime("%d/%m/%Y")},
          {content: @closing.to_s}
        ]
      ], cell_style: {borders: [], size: 12}) do
        row(0).font_style = :bold
        [1, 3].each { |col_index| cells[0, col_index].text_color = "00008b" }
      end
    end

    def other_header
      table([
        [
          {content: @monthly_report.envelope_number.to_s.rjust(5, "0")},
          {content: @monthly_report&.prescriber&.current_accounts.present? ? "" : "- (ESP)"}
        ]
      ], cell_style: {borders: [], size: 12}) do
        row(0).columns(1).text_color = "FF0000" unless @monthly_report&.prescriber&.current_accounts.present?
      end
    end

    def content
      headers = ["ID", "Nome", "Env.", "Informações", "Observação"]

      rows = [
        [
          @monthly_report.prescriber.id,
          @monthly_report.prescriber.name,
          @monthly_report.envelope_number.to_s.rjust(5, "0"),
          [
            @monthly_report&.prescriber&.full_address,
            @monthly_report&.prescriber&.full_contact,
            @monthly_report&.prescriber&.secretary
          ].compact.join("\n"),
          "OBS: #{truncate(@monthly_report&.prescriber&.note, length: 50)}"
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
        cell_style: {borders: [:bottom], border_width: 0.5, size: 8}) do
          [0, 1, 3].each do |col|
            columns(col).align = :center
            columns(col).valign = :center
          end

          if data.size <= 5
            [0, 3].each { |i| row(i).font_style = :bold }
          else
            [0, data.size - 2].each { |i| row(i).font_style = :bold }
          end
        end
    end
  end
end
