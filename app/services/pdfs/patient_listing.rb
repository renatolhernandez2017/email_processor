class Pdfs::PatientListing
  include Prawn::View
  include ActionView::Helpers::NumberHelper

  def initialize(representative, closing, closing_id)
    @representative = representative
    monthly_reports = @representative.set_monthly_reports(closing_id)
    @closing = closing

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
    headers = [
      "Paciente", "Repetida", "Data de Entrada",
      "Data de Pagamento", "Valor Recebido", "Filial"
    ]

    rows = @monthly_reports[:reports].flat_map do |monthly_report|
      monthly_report.prescriber.requests.map do |request|
        [
          request&.patient_name || "Sem Nome",
          request.repeat ? "-R" : "",
          request.entry_date.strftime("%d/%m/%y"),
          request.set_payment_date(request),
          request.set_price(request),
          request&.branch&.name || "Sem Filial"
        ]
      end
    end

    footer = [
      ["Quantidade", "", "", "Situação", "Número do Envelope", "Valor Disponível"],
      [
        @monthly_reports[:reports].sum(&:quantity),
        "", "",
        @monthly_reports[:info][1],
        @monthly_reports[:info][0].to_s.rjust(5, "0"),
        number_to_currency(@monthly_reports[:reports].sum(&:available_value))
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
        if data.size <= 5
          [0, 3].each { |i| row(i).font_style = :bold }
        else
          [0, data.size - 2].each { |i| row(i).font_style = :bold }
        end
      end
  end
end
