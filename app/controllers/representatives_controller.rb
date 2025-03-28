class RepresentativesController < ApplicationController
  include Pagy::Backend

  before_action :set_branches
  before_action :set_representatives
  before_action :set_representative, only: %i[update monthly_report]

  def index
    @pagy, @representatives = pagy(@representatives_map.order(created_at: :desc))

    @representative = Representative.new
    @current_account = CurrentAccount.new
    @current_account.build_bank
  end

  def update
    if @representative.update(representative_params)
      flash[:success] = "Representante atualizado com sucesso."
      render turbo_stream: turbo_stream.action(:redirect, representatives_path)
    else
      render turbo_stream: turbo_stream.replace("form_representative",
        partial: "representatives/form", locals: {
          representative: @representative,
          branches: @branches,
          title: "Novo fechamento",
          btn_save: "Salvar"
        })
    end
  end

  def monthly_report
    month_abbr = @current_closing.closing.split("/")
    @closing = "#{t("view.months.#{month_abbr[0]}")}/#{month_abbr[1]}"

    @monthly_reports = @representative.monthly_reports
      .where(closing_id: @current_closing.id)
      .joins(:prescriber).order("prescribers.name ASC")

    @accumulated = @monthly_reports.where(accumulated: true)
    @not_accumulated = @monthly_reports.where(accumulated: false)

    @totals_by_bank = @not_accumulated
      .group_by { |m| m.prescriber.current_accounts.find_by(standard: true)&.bank&.name }
      .map { |bank, monthly_report|
        {
          count: monthly_report.count,
          name: bank,
          total: monthly_report.sum(&:total_price)
        }
      }

    @total_count = @totals_by_bank.sum { |bank| bank[:count] }
    @total_value = @totals_by_bank.sum { |bank| bank[:total] }

    @totals_by_store = @not_accumulated
      .group_by { |m| m.representative&.branch&.name }
      .map { |branch, monthly_report|
        {
          count: monthly_report.count,
          name: branch,
          total: monthly_report.sum(&:total_price)
        }
      }
    # quebrar6
  end

  private

  def representative_params
    params.require(:representative).permit(
      :name,
      :partnership,
      :performs_closing,
      :branch_id
    )
  end

  def set_representative
    @representative = Representative.find_by(id: params[:id])
  end

  def set_branches
    @branches = Branch.pluck(:name, :id)
  end

  def set_representatives
    @representatives_map = Representative.all
  end
end
