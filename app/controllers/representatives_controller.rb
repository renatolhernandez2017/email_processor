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
    month_abbr = @current_closing.closing.split("/")[0]
    @closing = t("view.months.#{month_abbr}")

    @monthly_reports = @representative.monthly_reports.where(closing_id: @current_closing)

    # .where(monthly_reports: {closing_id: @current_closing})
    # @totais_de_relatorio = MonthlyReport.totais_gerais_por_filial(@current_closing)
    # @totais_por_representante = @totais_de_relatorio.group_by(&:representative_id)
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
