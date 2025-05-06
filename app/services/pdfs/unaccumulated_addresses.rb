class Pdfs::UnaccumulatedAddresses
  include Prawn::View
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper

  def initialize(representative, closing, current_closing)
    @representative = representative
    @closing = closing
    @monthly_reports = @representative.load_monthly_reports(current_closing.id, [{prescriber: {current_accounts: :bank}}])

    header
    move_down 10

    @monthly_reports.each do |monthly_report|
      @monthly_report = monthly_report
      content
    end
  end

  private

  def header
    table([
      [
        {content: "Clientes de"},
        {content: @representative.name.upcase},
        {content: "em"},
        {content: @closing.to_s}
      ]
    ], cell_style: {borders: [], size: 12}, position: :center) do
      row(0).font_style = :bold
      [1, 3].each { |col| cells[0, col].text_color = "00008b" }
    end
  end

  def content
    headers = ["Envelope", "Informações", "Quant.", "Valor Disp."]

    rows = [
      [
        @monthly_report.envelope_number.to_s.rjust(5, "0"),
        [
          "<b>Nome:</b> <color rgb='00008b'>#{@monthly_report&.prescriber&.name || "Sem Nome"}</color>",
          "<b>Endereço:</b> #{@monthly_report&.prescriber&.full_address || "Sem Endereço"}",
          "<b>Fones:</b> #{@monthly_report&.prescriber&.full_contact || "Sem Telefones"}",
          "<b>Contatos:</b> #{@monthly_report&.prescriber&.secretary || "Sem Contatos"}",
          "<b>OBS:</b> #{truncate(@monthly_report&.prescriber&.note, length: 50) || "Sem Observação"}"
        ].compact.join("\n"),
        @monthly_report.quantity,
        number_to_currency(@monthly_report.available_value)
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
