class CurrentAccountsController < ApplicationController
  include Pagy::Backend

  before_action :get_representatives
  before_action :set_route, only: %i[update]
  before_action :get_current_account, only: %i[update destroy change_standard]

  def index
    @pagy, @current_accounts = pagy(CurrentAccount.all.order(created_at: :desc))
  end

  def create
    @current_account = CurrentAccount.new(current_account_params)

    if @current_account.save
      flash[:success] = "Conta Corrente criada com sucesso!"
      render turbo_stream: turbo_stream.action(:redirect, representatives_path)
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

      if @route_name.present?
        render turbo_stream: turbo_stream.action(:redirect, representatives_path) if @route_name == "representative"
      else
        render turbo_stream: turbo_stream.action(:redirect, current_accounts_path)
      end
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
    render turbo_stream: turbo_stream.action(:redirect, representatives_path)
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

    render turbo_stream: turbo_stream.action(:redirect, representatives_path)
  end

  private

  def current_account_params
    params.require(:current_account).permit(
      :standard,
      :favored,
      :bank_id,
      :representative_id,
      bank_attributes: %i[name rounding agency_number account_number]
    )
  end

  def get_current_account
    @current_account = CurrentAccount.find(params[:id])
  end

  def get_representatives
    @representatives = Representative.all
  end

  def set_route
    @route_name = params[:route_name]
  end
end
