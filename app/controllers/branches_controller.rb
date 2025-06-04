class BranchesController < ApplicationController
  include Pagy::Backend
  include SharedData

  before_action :set_branch, only: %i[update]
  before_action :set_closing_date, only: %i[print_all_stores]

  def index
    @pagy, @branches = pagy(Branch.all.order(:branch_number))

    @current_account = CurrentAccount.new
    @current_account.build_bank
  end

  def update
    if @branch.update(branch_params)
      flash[:success] = "Filial atualizada com sucesso."
      render turbo_stream: turbo_stream.action(:redirect, branches_path)
    else
      render turbo_stream: turbo_stream.replace("form_branch",
        partial: "branchs/form", locals: {
          branch: @branch, title: "Novo current_closing", btn_save: "Salvar"
        })
    end
  end

  def print_all_stores
    @discounts = Discount.with_adjusted_discounts(closing_id: @current_closing&.id)

    @total_orders = Request.with_adjusted_totals(
      start_date: @current_closing&.start_date,
      end_date: @current_closing&.end_date
    )

    @total_billings = Request.with_adjusted_totals_billings(
      start_date: @current_closing&.start_date,
      end_date: @current_closing&.end_date
    )

    @billings = MonthlyReport.with_adjusted_billings(closing_id: @current_closing&.id)
  end

  private

  def branch_params
    params.require(:branch).permit(
      :name,
      :branch_number,
      :discount_request
    )
  end

  def set_branch
    @branch = Branch.find_by(id: params[:id])
  end

  def set_closing_date
    month_abbr = @current_closing&.closing&.split("/")
    @closing = "#{t("view.months.#{month_abbr[0]}")}/#{month_abbr[1]}" if month_abbr.present?
  end
end
