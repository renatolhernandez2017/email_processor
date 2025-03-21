class RepresentativesController < ApplicationController
  include Pagy::Backend

  before_action :get_branches, :get_representatives
  before_action :get_representative, only: %i[update]

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

  private

  def representative_params
    params.require(:representative).permit(
      :name,
      :partnership,
      :performs_closing,
      :branch_id
    )
  end

  def get_representative
    @representative = Representative.find(params[:id])
  end

  def get_branches
    @branches = Branch.all.map { |branch| [branch.name, branch.id] }
  end

  def get_representatives
    @representatives_map = Representative.all
  end
end
