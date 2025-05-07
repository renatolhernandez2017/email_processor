class Pdfs::Tags
  include Prawn::View
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper

  def initialize(representatives, closing, current_closing)
    @closing = closing
    @current_closing = current_closing

    representatives.each_with_index do |representative, index|
      start_new_page unless index == 0
      @representative = representative

      @representative.monthly_reports.each do |monthly_report|
        @monthly_report = monthly_report

        header
        move_down 5

        content
      end
    end
  end

  private

  def header
    table([
      [
        {content: "Etiquetas de"},
        {content: @representative.name.upcase},
        {content: "-"},
        {content: @current_closing.end_date.strftime("%d/%m/%Y")},
        {content: @closing.to_s},
        {content: @monthly_report&.prescriber&.current_accounts.nil? ? "(ESP) -" : ""},
        {content: @monthly_report.envelope_number.to_s.rjust(5, "0")}
      ]
    ], cell_style: {borders: [], size: 12}, position: :center) do
      row(0).font_style = :bold
      [1].each { |col_index| cells[0, col_index].text_color = "00008b" }
    end
  end

  def content
    headers = ["ID", "Nome", "Informações", "Observação"]

    rows = [
      [
        @monthly_report.prescriber.id,
        @monthly_report.prescriber.name,
        [
          "<p>#{@monthly_report&.prescriber&.full_address}</p>",
          "<p>#{@monthly_report&.prescriber&.full_contact}</p>",
          "<p>#{@monthly_report&.prescriber&.secretary}</p>"
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
        if data.size <= 5
          [0, 3].each { |i| row(i).font_style = :bold }
        else
          [0, data.size - 2].each { |i| row(i).font_style = :bold }
        end
      end
  end
end
