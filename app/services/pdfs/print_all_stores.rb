module Pdfs
  class PrintAllStores < BaseBranchPdf
    def generate_content
      @branches.each_with_index do |(name, branch_number, id), index|
        start_new_page unless index == 0

        @branch_name = name
        @branch_number = branch_number
        @branch_id = id

        @new_loose = @loose[@branch_id]
        @new_total_revenue = @total_revenue[@branch_id]
        @new_with_partnership = @with_partnership[@branch_name]
        @with_partnership_by_representative = @new_with_partnership&.group_by(&:representative_name)

        if @new_with_partnership
          header
          content
        end
      end
    end

    def header
      table([
        [
          {content: "Todas as lojas de"},
          {content: @branch_name.upcase},
          {content: "em"},
          {content: @closing}
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
      total_orders
      move_down 20
      billings
      move_down 20
      full_partnership
      move_down 20
      other_informations
      move_down 20
      commission_payments
      move_down 20
    end

    def total_orders
      headers = [
        "Quantidade de Receitas", "Valor médio da Receita",
        "Total de Descontos", "", "Total de Taxas"
      ]

      rows = [
        [
          @new_loose.quantity,
          number_to_currency(@new_loose.adjusted_revenue_value),
          number_to_currency(@new_loose.total_discounts),
          "",
          number_to_currency(@new_loose.total_fees)
        ]
      ]

      footer = [
        [
          "Total de Pedidos",
          "", "", "",
          number_to_currency(@new_loose.total_orders)
        ]
      ]

      data = build_table_data(headers: headers, rows: rows, footer: footer)
      render_table(data, "total_orders")
    end

    def billings
      headers = ["Avulso", "", "", "", "Com parceria"]

      rows = [
        [
          if @branch_number != 13
            number_to_currency((@new_total_revenue.amount_received - @new_with_partnership.sum(&:total_requests)) || 0)
          else
            number_to_currency(((@new_total_revenue.amount_received / 0.85) - @new_with_partnership.sum(&:total_requests)) || 0)
          end,
          "", "", "",
          number_to_currency(@new_with_partnership.sum(&:total_requests) || 0)
        ]
      ]

      footer = [
        [
          "Faturamento",
          "", "", "",
          number_to_currency(@new_total_revenue.billing || 0)
        ]
      ]

      data = build_table_data(headers: headers, rows: rows, footer: footer)
      render_table(data, "billings")
    end

    def full_partnership
      headers = ["Em dinheiro", "", "", "", "Em bancos"]

      rows = [
        [
          number_to_currency(@new_with_partnership.sum(&:branch_partnership)),
          "", "", "",
          number_to_currency(@new_with_partnership.sum(&:total_discounts))
        ]
      ]

      footer = [
        [
          "Parceria total",
          "", "", "",
          number_to_currency(@new_with_partnership.sum(&:branch_partnership) + @new_with_partnership.sum(&:total_discounts)) + " " + "(-)"
        ]
      ]

      data = build_table_data(headers: headers, rows: rows, footer: footer)
      render_table(data, "full_partnership")
    end

    def other_informations
      headers = []
      rows = [
        [
          "Parceria adiantada pela loja",
          "", "", "",
          number_to_currency(@new_with_partnership.sum(&:total_discounts)) + " " + "(+)"
        ],
        [
          "Pagamento de comissão para representantes",
          "", "", "",
          number_to_currency(@new_with_partnership.sum(&:commission_payments_transfers)) + " " + "(-) ver tabela abaixo"
        ],
        [
          "Repasse de comissão para representantes",
          "", "", "",
          number_to_currency(@new_with_partnership.sum(&:commission_payments_transfers)) + " " + "(+) ver tabela abaixo"
        ],
        [
          "Total devido",
          "", "", "",
          number_to_currency(@new_with_partnership.sum(&:branch_partnership)) + " " + "(=)"
        ]
      ]
      footer = []

      data = build_table_data(headers: headers, rows: rows, footer: footer)
      render_table(data, "other_informations")
    end

    def commission_payments
      headers = ["Representante", "Quantidade", "Venda", "Comissão", "Total"]

      rows = @with_partnership_by_representative.map do |representative_name, partnership_by_representative|
        [
          representative_name,
          partnership_by_representative.sum(&:number_of_requests) || 0,
          number_to_currency(partnership_by_representative.sum(&:total_requests) || 0),
          formatted_percentage(partnership_by_representative[0].commission || 0),
          number_to_currency(partnership_by_representative.sum(&:commission_payments_transfers) || 0)
        ]
      end

      footer = [
        [
          "Totais",
          @new_with_partnership.sum(&:number_of_requests) || 0,
          number_to_currency(@new_with_partnership.sum(&:total_requests) || 0),
          "",
          number_to_currency(@new_with_partnership.sum(&:commission_payments_transfers) || 0)
        ]
      ]

      data = build_table_data(headers: headers, rows: rows, footer: footer)
      render_table(data, "commission")
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
