class RepresentativesController < ApplicationController
  include Pagy::Backend

  before_action :set_branches, :set_representatives
  before_action :set_representative, only: %i[update]

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
