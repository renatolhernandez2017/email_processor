class RepresentativesController < ApplicationController
  include Pagy::Backend

  before_action :get_branches
  before_action :get_representative, only: %i[update show]

  def index
    @pagy, @representatives = pagy(Representative.all.order(created_at: :desc))

    @representative = Representative.new
  end

  def update
    update_bank

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

  def show
  end

  private

  def representative_params
    params.require(:representative).permit(
      :name,
      :partnership,
      :performs_closing,
      :branch_id,
      :current_account_id
    )
  end

  def get_representative
    @representative = Representative.find(params[:id])
  end

  def get_branches
    @branches = Branch.all.map { |b| [b.name, b.id] }
  end

  def update_bank
    if params.dig("representative", "current_account_attributes", "bank_attributes").present?
      bank_params = params["representative"]["current_account_attributes"]["bank_attributes"]

      bank = {
        name: bank_params["name"],
        agency_number: bank_params["agency_number"],
        account_number: bank_params["account_number"]
      }

      @representative.current_account.bank.update(bank) if bank.present?
    end
  end
end
