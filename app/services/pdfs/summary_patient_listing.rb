class Pdfs::SummaryPatientListing
  include Prawn::View
  include ActionView::Helpers::NumberHelper

  def initialize(representative, closing, current_closing)
    @representative = representative
    @closing = closing
    monthly_reports = @representative.set_monthly_reports(current_closing.id)

    header
    move_down 10

    monthly_reports.each do |reports|
      @monthly_reports = reports
      content
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
    move_down 10
    headers = ["Quantidade", "Situação", "Envelope", "Valor Disponível"]

    rows = [
      [
        @monthly_reports[:reports].sum(&:quantity),
        @monthly_reports[:info][1],
        @monthly_reports[:info][0].to_s.rjust(5, "0"),
        number_to_currency(@monthly_reports[:reports].sum(&:available_value))
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
