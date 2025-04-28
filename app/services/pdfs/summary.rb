class Pdfs::Summary
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

    calculate_totals_by_bank
    calculate_totals_by_store
    calculate_totals_note_division

    header
    content
  end

  private

  def calculate_totals_by_bank
    @total_count = @totals_by_bank.sum { |bank| bank[:count] if bank.present? }
    @total_value = @totals_by_bank.sum { |bank| bank[:total] if bank.present? }
  end

  def calculate_totals_by_store
    @total_count_store = @totals_by_store.sum { |store| store[:count] }
    @total_store = @totals_by_store.sum { |store| store[:total] }
  end

  def calculate_totals_note_division
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
    generate_table
    move_down 20

    table_by_bank
    move_down 20

    table_by_store
    move_down 20

    table_by_notes
    move_down 20
  end

  def table_by_bank
    text "Total por Banco", size: 12, style: :bold, color: "00008b"
    data = [
      [
        "Quantidade", "Loja", "Valor"
      ]
    ]

    @totals_by_bank.each do |bank|
      data << [
        bank[:count] || 0,
        bank[:name] || "N/A",
        number_to_currency(bank[:total] || 0)
      ]
    end

    data << Array.new(3, "")

    data << [
      "Total de Bancos",
      "", "Total"
    ]

    data << [
      @total_count || 0,
      "", number_to_currency(@total_value || 0)
    ]

    table(data.compact,
      header: true,
      row_colors: ["F0F0F0", "FFFFFF"],
      width: bounds.width,
      cell_style: {borders: [:bottom], border_width: 0.5, size: 8}) do
        row(0).font_style = :bold
        row(2).font_style = :bold
      end
  end

  def table_by_store
    text "Total por loja", size: 12, style: :bold, color: "00008b"
    data1 = [
      [
        "Quantidade", "Loja", "Valor"
      ]
    ]

    @totals_by_store.each do |store|
      data1 << [
        store[:count] || 0,
        store[:name] || "N/A",
        number_to_currency(store[:total] || 0)
      ]
    end

    data1 << Array.new(3, "")

    data1 << [
      "Total de Lojas",
      "", "Total"
    ]

    data1 << [
      @total_count_store || 0,
      "", number_to_currency(@total_store || 0)
    ]

    table(data1.compact,
      header: true,
      row_colors: ["F0F0F0", "FFFFFF"],
      width: bounds.width,
      cell_style: {borders: [:bottom], border_width: 0.5, size: 8}) do
        row(0).font_style = :bold
        row(2).font_style = :bold
      end
  end

  def table_by_notes
    text "Divisão de Notas", size: 12, style: :bold, color: "00008b"
    data2 = [
      [
        "Quantidade", "Notas", "Valor"
      ]
    ]

    @total_in_cash.each do |item, cash|
      data2 << [
        cash || 0,
        item || "N/A",
        number_to_currency((cash * item) || 0)
      ]
    end

    data2 << Array.new(3, "")

    data2 << [
      "Total de Notas",
      "", "Total"
    ]

    data2 << [
      @total_marks || 0,
      "", number_to_currency(@total_cash || 0)
    ]

    table(data2.compact,
      header: true,
      row_colors: ["F0F0F0", "FFFFFF"],
      width: bounds.width,
      cell_style: {borders: [:bottom], border_width: 0.5, size: 8}) do
        row(0).font_style = :bold
        row(2).font_style = :bold
      end
  end

  def generate_table
    data = [
      [
        "Id", "Prescritor", "Qt.", "Total", "Parceria",
        "Descontos", "Valor Disp.", "Tipo", "N. Envelope"
      ]
    ]

    @monthly_reports.each do |monthly_report|
      data << [
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

    data << Array.new(9, "")

    totals = total_or_accumulated(@monthly_reports)
    accumulated = total_or_accumulated(@accumulated)
    real_sale = real_sale(@monthly_reports, @accumulated)

    data << [
      "Quantidade", "", "", "", "", "", "", "", ""
    ]

    data << [
      totals[:count] || 0,
      "Total Geral",
      totals[:quantity] || 0,
      number_to_currency(totals[:total_price] || 0),
      number_to_currency(totals[:partnership] || 0),
      number_to_currency(totals[:discounts] || 0),
      number_to_currency(totals[:available_value] || 0),
      "", ""
    ]

    data << [
      accumulated[:count] || 0,
      "Acumulados",
      accumulated[:quantity] || 0,
      number_to_currency(accumulated[:total_price] || 0),
      number_to_currency(accumulated[:partnership] || 0),
      number_to_currency(accumulated[:discounts] || 0),
      number_to_currency(accumulated[:available_value] || 0),
      "", ""
    ]

    data << [
      real_sale[:count] || 0,
      "Venda Real",
      real_sale[:quantity] || 0,
      number_to_currency(real_sale[:total_price] || 0),
      number_to_currency(real_sale[:partnership] || 0),
      number_to_currency(real_sale[:discounts] || 0),
      number_to_currency(real_sale[:available_value] || 0),
      "", ""
    ]

    table(data.compact,
      header: true,
      row_colors: ["F0F0F0", "FFFFFF"],
      width: bounds.width,
      cell_style: {borders: [:bottom], border_width: 0.5, size: 8}) do
        row(0).font_style = :bold
        row(3).font_style = :bold
        cells[1, 1].text_color = "00008b"
        cells[4, 1].font_style = :bold
        cells[5, 1].font_style = :bold
        cells[6, 1].font_style = :bold
      end
  end
end
