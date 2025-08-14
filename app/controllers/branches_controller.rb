class BranchesController < ApplicationController
  include Pagy::Backend
  include SharedData
  include PdfClassMapper

  before_action :set_branch, only: %i[update]

  def index
    @pagy, @branches = pagy(Branch.all.order(:branch_number))

    if params[:query].present?
      @branches = @branches.search_global(params[:query])
    end

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
    @loose = Request.with_adjusted_totals(@current_closing.start_date, @current_closing.end_date, @current_closing.id)
    @total_revenue = Request.with_adjusted_totals_billings(@current_closing.start_date, @current_closing.end_date, @current_closing.id)
    @with_partnership = MonthlyReport.with_adjusted_billings(@current_closing.id)
  end

  def download_pdf
    kind = params[:kind]
    pdf_class = PDF_CLASSES[kind]
    pdf = pdf_class.new(@branches, @current_closing).render

    send_data pdf,
      filename: "#{kind}_#{@current_closing.closing.downcase}.pdf",
      type: "application/pdf",
      disposition: "inline" # ou "attachment" se quiser forçar download
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
end
