module Pdfs
  class PrintAllStores < BaseBranchPdf
    def generate_content
      @branches.each_with_index do |(name, number, id), index|
        start_new_page if index > 0

        if @with_partnership[name]
          header(name)
          move_down 20

          total_orders(@loose[id])
          move_down 20

          billings(number, @total_revenue[id], @with_partnership[name])
          move_down 20

          full_partnership(@with_partnership[name])
          move_down 20

          other_informations(@with_partnership[name])
          move_down 20

          commission_payments(@with_partnership[name])
          move_down 20
        end
      end
    end

    def header(branch_name)
      table([
        [
          {content: "Filial"},
          {content: branch_name.upcase},
          {content: "em"},
          {content: @current_closing.closing}
        ]
      ], cell_style: {borders: [], size: 12}, position: :center) do
        row(0).font_style = :bold
        [1, 3].each do |col|
          columns(col).text_color = "00008b"
        end
      end
    end

    def total_orders(loose)
      headers = [
        "Quantidade de Receitas", "Valor médio da Receita",
        "Total de Descontos", "Total de Taxas", "Total de Pedidos"
      ]

      rows = [
        [
          loose&.quantity,
          number_to_currency(loose&.adjusted_revenue_value),
          number_to_currency(loose&.total_discounts),
          number_to_currency(loose&.total_fees),
          number_to_currency(loose&.total_orders)
        ]
      ]

      data = build_table_data(headers: headers, rows: rows, footer: footer = [])
      render_table(data, "total_orders")
    end

    def billings(branch_number, total_revenue, with_partnership)
      headers = ["Avulso", "Com parceria", "Faturamento"]

      rows = [
        [
          number_to_currency(((total_revenue.amount_received / 0.85) - with_partnership.sum(&:total_requests)) || 0),
          number_to_currency(with_partnership.sum(&:total_requests) || 0),
          number_to_currency(total_revenue.billing || 0)
        ]
      ]

      data = build_table_data(headers: headers, rows: rows, footer: footer = [])
      render_table(data, "billings")
    end

    def full_partnership(with_partnership)
      headers = ["Em dinheiro", "Em bancos", "Parceria total"]

      rows = [
        [
          number_to_currency(with_partnership.sum(&:branch_partnership)),
          number_to_currency(with_partnership.sum(&:total_discounts)),
          number_to_currency(with_partnership.sum(&:branch_partnership) + with_partnership.sum(&:total_discounts)) + " " + "(-)"
        ]
      ]

      data = build_table_data(headers: headers, rows: rows, footer: footer = [])
      render_table(data, "full_partnership")
    end

    def other_informations(with_partnership)
      headers = []
      rows = [
        [
          "Parceria adiantada pela loja",
          "", "", "",
          number_to_currency(with_partnership.sum(&:total_discounts)) + " " + "(+)"
        ],
        [
          "Pagamento de comissão para representantes",
          "", "", "",
          number_to_currency(with_partnership.sum(&:commission_payments_transfers)) + " " + "(-) ver tabela abaixo"
        ],
        [
          "Repasse de comissão para representantes",
          "", "", "",
          number_to_currency(with_partnership.sum(&:commission_payments_transfers)) + " " + "(+) ver tabela abaixo"
        ],
        [
          "Total devido",
          "", "", "",
          number_to_currency(with_partnership.sum(&:branch_partnership)) + " " + "(=)"
        ]
      ]
      footer = []

      data = build_table_data(headers: headers, rows: rows, footer: footer)
      render_table(data, "other_informations")
    end

    def commission_payments(with_partnership)
      headers = ["Representante", "Quantidade", "Venda", "Comissão", "Total"]

      rows = with_partnership&.group_by(&:representative_name)&.map do |representative_name, by_representative|
        [
          representative_name,
          by_representative.sum(&:number_of_requests) || 0,
          number_to_currency(by_representative.sum(&:total_requests) || 0),
          formatted_percentage(by_representative[0].commission || 0),
          number_to_currency(by_representative.sum(&:commission_payments_transfers) || 0)
        ]
      end

      footer = [
        [
          "Totais",
          with_partnership.sum(&:number_of_requests) || 0,
          number_to_currency(with_partnership.sum(&:total_requests) || 0),
          "",
          number_to_currency(with_partnership.sum(&:commission_payments_transfers) || 0)
        ]
      ]

      data = build_table_data(headers: headers, rows: rows, footer: footer)
      render_table(data, "commission")
    end

    def formatted_percentage(value)
      number_to_percentage(value, precision: 2)
    end

    def build_table_data(headers:, rows:, footer: [])
      data = [headers]
      data.concat(rows)
      data << Array.new(headers.size, "")
      data.concat(footer)
      data
    end

    def render_table(data, type)
      table(data.compact,
        header: true,
        row_colors: ["F0F0F0", "FFFFFF"],
        width: bounds.width,
        cell_style: {borders: [:bottom], border_width: 0.5, size: 7.5}) do
          row(0).font_style = :bold

          case type
          when "total_orders"
            row(3).font_style = :bold if data.size <= 4
          when "billings", "full_partnership"
            row(3).font_style = :bold if data.size <= 4
          when "other_informations"
            (0..3).each { |i| row(i).font_style = :bold }
          when "commission"
            row(0).font_style = :bold if data.size <= 2

            if data.size >= 3
              row(data.size - 1).font_style = :bold

              (1..data.size - 2).each { |i|
                cells[i, 0].text_color = "00008b"
                cells[i, 0].font_style = :bold
                cells[i, 4].text_color = "00008b"
                cells[i, 4].font_style = :bold
              }
            end
          end
        end
    end
  end
end
