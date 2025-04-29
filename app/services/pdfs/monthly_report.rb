class Pdfs::MonthlyReport
  include Prawn::View
  include ActionView::Helpers::NumberHelper
  include MonthlyReportsHelper

  def initialize(representative, closing, current_closing)
    @representative = representative
    @closing = closing
    @monthly_reports = @representative.load_monthly_reports(current_closing.id, [{prescriber: {current_accounts: :bank}}])
    @accumulated = @monthly_reports.where(accumulated: false)
    @totals_by_bank = @representative.totals_by_bank(current_closing.id)
    @totals_by_store = @representative.totals_by_store(current_closing.id)
    @total_in_cash = @representative.total_cash(current_closing.id)

    totals_calculate
    header
    content
  end

  private

  def totals_calculate
    @total_count = @totals_by_bank.sum { |bank| bank[:count] if bank.present? }
    @total_value = @totals_by_bank.sum { |bank| bank[:total] if bank.present? }
    @total_count_store = @totals_by_store.sum { |store| store[:count] }
    @total_store = @totals_by_store.sum { |store| store[:total] }
    @total_marks = @total_in_cash.values.sum
    @total_cash = @total_in_cash.map { |key, value| key * value }.sum
  end

  def header
    formatted_text [
      {text: "Resumo de ", size: 12},
      {text: @representative.name.upcase.to_s, size: 12, color: "00008b"},
      {text: " em ", size: 12},
      {text: @closing.to_s, size: 12, color: "00008b"}
    ], align: :center
  end

  def content
    move_down 20
    table_monthly_reports
    move_down 20

    table_by_bank
    move_down 20

    table_by_store
    move_down 20

    table_by_notes
    move_down 20
  end

  def table_monthly_reports
    headers = [
      "Id", "Prescritor", "Qt.", "Total", "Parceria",
      "Descontos", "Valor Disp.", "Tipo", "N. Envelope"
    ]

    rows = @monthly_reports.map do |monthly_report|
      [
        monthly_report.id || "N/A",
        monthly_report&.prescriber&.name || "N/A",
        monthly_report.quantity || "N/A",
        number_to_currency(monthly_report.total_price || 0),
        number_to_currency(monthly_report.partnership || 0),
        number_to_currency(monthly_report.discounts || 0),
        number_to_currency(monthly_report.available_value || 0),
        payment_method_display(monthly_report).to_s || "N/A",
        monthly_report.envelope_number.to_s.rjust(6, "0")
      ]
    end

    footer = build_monthly_reports_footer
    data = build_table_data(headers: headers, rows: rows, footer: footer)

    render_table(data, "reports")
  end

  def table_by_bank
    build_generic_table(
      title: "Total por Banco",
      headers: ["Quantidade", "Banco", "Valor"],
      rows: @totals_by_bank.map { |b| [b[:count] || 0, b[:name] || "N/A", number_to_currency(b[:total] || 0)] },
      footer: [["Total de Bancos", "", "Total"], [@total_count || 0, "", number_to_currency(@total_value || 0)]],
      type: "banks"
    )
  end

  def table_by_store
    build_generic_table(
      title: "Total por Loja",
      headers: ["Quantidade", "Loja", "Valor"],
      rows: @totals_by_store.map { |b| [b[:count] || 0, b[:name] || "N/A", number_to_currency(b[:total] || 0)] },
      footer: [["Total de Lojas", "", "Total"], [@total_count_store || 0, "", number_to_currency(@total_store || 0)]],
      type: "stores"
    )
  end

  def table_by_notes
    build_generic_table(
      title: "Divisão de Notas",
      headers: ["Quantidade", "Notas", "Valor"],
      rows: @total_in_cash.map { |item, cash| [cash || 0, item || "N/A", number_to_currency(cash * item || 0)] },
      footer: [["Total de Notas", "", "Total"], [@total_marks || 0, "", number_to_currency(@total_cash || 0)]],
      type: "notes"
    )
  end

  def build_monthly_reports_footer
    totals = total_or_accumulated(@monthly_reports)
    accumulated = total_or_accumulated(@accumulated)
    real_sale = real_sale(@monthly_reports, @accumulated)

    [
      ["Quantidade", "", "", "", "", "", "", "", ""],
      [
        totals[:count] || 0,
        "Total Geral",
        totals[:quantity] || 0,
        number_to_currency(totals[:total_price] || 0),
        number_to_currency(totals[:partnership] || 0),
        number_to_currency(totals[:discounts] || 0),
        number_to_currency(totals[:available_value] || 0),
        "", ""
      ],
      [
        accumulated[:count] || 0,
        "Acumulados",
        accumulated[:quantity] || 0,
        number_to_currency(accumulated[:total_price] || 0),
        number_to_currency(accumulated[:partnership] || 0),
        number_to_currency(accumulated[:discounts] || 0),
        number_to_currency(accumulated[:available_value] || 0),
        "", ""
      ],
      [
        real_sale[:count] || 0,
        "Venda Real",
        real_sale[:quantity] || 0,
        number_to_currency(real_sale[:total_price] || 0),
        number_to_currency(real_sale[:partnership] || 0),
        number_to_currency(real_sale[:discounts] || 0),
        number_to_currency(real_sale[:available_value] || 0),
        "", ""
      ]
    ]
  end

  def build_table_data(headers:, rows:, footer: [])
    data = [headers]
    data.concat(rows)
    data << Array.new(headers.size, "")
    data.concat(footer)
    data
  end

  def build_generic_table(title:, headers:, rows:, footer:, type:)
    text title, size: 12, style: :bold, color: "00008b"
    data = build_table_data(headers: headers, rows: rows, footer: footer)
    render_table(data, type)
  end

  def render_table(data, type)
    table(data.compact,
      header: true,
      row_colors: ["F0F0F0", "FFFFFF"],
      width: bounds.width,
      cell_style: {borders: [:bottom], border_width: 0.5, size: 8}) do
        row(0).font_style = :bold
        cells[1, 1].text_color = "00008b" if type == "reports"
        row(2).font_style = :bold if type == "banks"
        row(3).font_style = :bold if type == "stores"
        row(5).font_style = :bold if type == "notes"
        cells[3, 0].font_style = :bold if type == "reports"
        cells[4, 1].font_style = :bold if data.size > 4
        cells[5, 1].font_style = :bold if data.size > 5
        cells[6, 1].font_style = :bold if data.size > 6
      end
  end
end
