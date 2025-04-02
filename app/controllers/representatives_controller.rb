class RepresentativesController < ApplicationController
  include Pagy::Backend
  include Roundable

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
    set_closing_date

    @monthly_reports = @representative.load_monthly_reports(@current_closing.id)
    @accumulated = @monthly_reports.where(accumulated: true)

    calculate_totals_by_bank
    calculate_totals_by_store
    calculate_cash_totals
  end

  def calculate_totals_by_bank
    @totals_by_bank = @representative.totals_by_bank(@current_closing.id)
    @total_count = @totals_by_bank.sum { |bank| bank[:count] }
    @total_value = @totals_by_bank.sum { |bank| bank[:total] }
  end

  def calculate_totals_by_store
    @totals_by_store = @representative.totals_by_store(@current_closing.id)
    @total_count_store = @totals_by_store.sum { |store| store[:count] }
    @total_store = @totals_by_store.sum { |store| store[:total] }
  end

  def calculate_cash_totals
    @total_in_cash = @representative.total_cash(@current_closing.id)
    @total_marks = @total_in_cash.values.sum
    @total_cash = @total_in_cash.map { |key, value| key * value }.sum
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

  def set_closing_date
    month_abbr = @current_closing.closing.split("/")
    @closing = "#{t("view.months.#{month_abbr[0]}")}/#{month_abbr[1]}"
  end
end
