class CurrentAccountsController < ApplicationController
  include Pagy::Backend
  include Redirectable

  before_action :get_representatives
  before_action :get_current_account, only: %i[update destroy change_standard]

  def index
    @pagy, @current_accounts = pagy(CurrentAccount.all.order(created_at: :desc))
  end

  def create
    @current_account = CurrentAccount.new(current_account_params)

    if @current_account.save
      flash[:success] = "Conta Corrente criada com sucesso!"

      render_redirect
    else
      render turbo_stream: turbo_stream.replace("form_current_account",
        partial: "current_accounts/form", locals: {
          current_account: @current_account,
          representatives: @representatives,
          title: "Novo fechamento",
          btn_save: "Salvar",
          route_name: "representative"
        })
    end
  end

  def update
    if @current_account.update(current_account_params)
      flash[:success] = "Conta Corrente atualizada com sucesso."

      render_redirect
    else
      render turbo_stream: turbo_stream.replace("form_current_account",
        partial: "current_accounts/form", locals: {
          current_account: @current_account, title: "Novo fechamento", btn_save: "Salvar"
        })
    end
  end

  def destroy
    @current_account.destroy

    flash[:success] = "Conta Corrente apagada com sucesso."

    render_redirect
  end

  def change_standard
    case params[:type]
    when "active"
      @current_account.update(standard: true)

      flash[:info] = "Conta Corrente ativada com sucesso."
    when "desactive"
      @current_account.update(standard: false)

      flash[:info] = "Conta Corrente desativada com sucesso."
    end

    render_redirect
  end

  private

  def current_account_params
    params.require(:current_account).permit(
      :standard,
      :favored,
      :bank_id,
      :representative_id,
      :prescriber_id,
      :branch_id,
      bank_attributes: %i[name rounding agency_number account_number]
    )
  end

  def get_current_account
    @current_account = CurrentAccount.find(params[:id])
  end

  def get_representatives
    @representatives = Representative.all
  end
end
