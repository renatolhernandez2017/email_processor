class Pdfs::PatientListing
  include Prawn::View
  include ActionView::Helpers::NumberHelper
  include MonthlyReportsHelper

  def initialize(representative, monthly_reports, closing)
    @representative = representative
    @closing = closing
    @monthly_reports = monthly_reports

    header
    move_down 10

    @monthly_reports.each do |monthly_report|
      @monthly_report = monthly_report

      @monthly_report.requests.map do |request|
        @request = request
        content
      end
    end
  end

  private

  def header
    table([
      [
        {content: "Listagem de Pacientes de "},
        {content: @representative.name.upcase},
        {content: " em "},
        {content: @closing.to_s}
      ]
    ], cell_style: {borders: [], size: 12}, position: :center) do
      row(0).font_style = :bold
      cells[0, 1].text_color = "00008b"
      cells[0, 3].text_color = "00008b"
    end
  end

  def content
    move_down 10

    headers = [
      "Paciente", "Repetida", "Data de Entrada",
      "Data de Pagamento", "Valor Recebido", "Filial"
    ]

    rows = [
      [
        @request&.patient_name || "Sem Nome",
        @request.repeat ? "-R" : "",
        @request.entry_date.strftime("%d/%m/%y"),
        @request.set_payment_date(@request),
        @request.set_price(@request),
        @request.branch.name
      ]
    ]

    footer = [
      ["Quantidade", "", "", "Situação", "Número do Envelope", "Valor Disponível"],
      [
        @monthly_report.quantity,
        "", "",
        @monthly_report.situation,
        @monthly_report.envelope_number.to_s.rjust(5, "0"),
        number_to_currency(@monthly_report.available_value)
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
        [0, 3].each do |col|
          row(col).font_style = :bold
        end
      end
  end
end
