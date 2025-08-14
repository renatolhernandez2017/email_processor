module Pdfs
  class ClosingAudit < BaseClosingPdf
    def generate_content
      header
      content
    end

    def header
      table([
        [
          {content: "Auditoria de Fechamento de"},
          {content: @current_closing.closing}
        ]
      ], cell_style: {borders: [], size: 12}, position: :center) do
        row(0).font_style = :bold
        [1, 3].each do |col|
          columns(col).text_color = "00008b"
        end
      end
    end

    def content
      move_down 20
      store_collections
      move_down 20
      payment_for_representative
      move_down 20
      as_follow
      move_down 20
    end

    def store_collections
      build_generic_table(
        title: "(+) Arrecadação de lojas",
        headers: ["Filial", "Qt. receitas", "Valor parceria"],
        rows: @store_collections.map { |branch_name, monthly_reports| [branch_name, monthly_reports.sum(&:number_of_requests), number_to_currency(monthly_reports.sum(&:branch_partnership))] },
        footer: [["Totais", @store_total_quantity, number_to_currency(@store_total_value)]]
      )
    end

    def payment_for_representative
      build_generic_table(
        title: "(-) Pagamento para representantes",
        headers: ["Representante", "Qt. receitas", "Valor parceria"],
        rows: @payments.map { |representative_name, monthly_reports| [representative_name, monthly_reports.sum(&:quantity), number_to_currency(monthly_reports.sum(&:available_value))] },
        footer: [["Totais", @total_quantity, number_to_currency(@total_value)]]
      )
    end

    def as_follow
      build_generic_table(
        title: "(=) ... da seguinte forma",
        headers: ["Destino", "Qt. relatorios", "Valor"],
        rows: @as_follows.map { |bank_name, monthly_reports| [bank_name || "DINHEIRO", monthly_reports.sum(&:quantity), number_to_currency(monthly_reports.sum(&:available_value))] },
        footer: [["Totais", @as_follow_total_quantity, number_to_currency(@as_follow_total_value)]]
      )
    end

    def build_table_data(headers:, rows:, footer: [])
      data = [headers]
      data.concat(rows)
      data << Array.new(headers.size, "")
      data.concat(footer)
      data
    end

    def build_generic_table(title:, headers:, rows:, footer:)
      text title, size: 12, style: :bold, color: "00008b"
      data = build_table_data(headers: headers, rows: rows, footer: footer)
      render_table(data)
    end

    def render_table(data)
      table(data.compact,
        header: true,
        row_colors: ["F0F0F0", "FFFFFF"],
        width: bounds.width,
        cell_style: {borders: [:bottom], border_width: 0.5, size: 6.5}) do
          row(0).font_style = :bold

          row(data.size - 1).font_style = :bold
        end
    end
  end
end
