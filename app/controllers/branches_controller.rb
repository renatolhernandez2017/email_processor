class BranchesController < ApplicationController
  include Pagy::Backend

  before_action :set_branches
  before_action :set_branch, only: %i[update]

  def index
    @pagy, @branches = pagy(@branches_map.order(created_at: :desc))

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
          branch: @branch, title: "Novo fechamento", btn_save: "Salvar"
        })
    end
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

  def set_branches
    @branches_map = Branch.all
  end
end
