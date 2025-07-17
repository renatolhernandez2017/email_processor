module Pdfs
  class Tags < BaseMonthlyPdf
    def generate_content
      @representatives.each_with_index do |representative, index|
        start_new_page unless index == 0
        @representative = representative

        header
        move_down 5

        @monthly_reports[@representative.id].each do |monthly_report|
          @monthly_report = monthly_report
          @prescriber = @monthly_report.prescriber

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
      current_accounts = @prescriber.current_accounts
      table([
        [
          {content: @monthly_report.number_envelope},
          {content: current_accounts.present? ? "" : "- (ESP)"}
        ]
      ], cell_style: {borders: [], size: 12}) do
        row(0).columns(1).text_color = "FF0000" unless current_accounts.present?
      end
    end

    def content
      headers = ["ID", "Nome", "Env.", "Informações", "Observação"]

      rows = [
        [
          @prescriber.id,
          @prescriber.name,
          @monthly_report.number_envelope,
          [
            @prescriber&.full_address,
            @prescriber&.full_contact,
            @prescriber.secretary
          ].compact.join("\n"),
          "OBS: #{truncate(@prescriber.note, length: 50)}"
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
