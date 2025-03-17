class BranchesController < ApplicationController
  include Pagy::Backend

  before_action :get_branch, only: %i[update]

  def index
    @pagy, @branches = pagy(Branch.all.order(created_at: :desc))
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

  def get_branch
    @branch = Branch.find(params[:id])
  end
end
