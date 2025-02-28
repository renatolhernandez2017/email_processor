# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  def new
    if params[:user].present?
      user = User.search_global(params[:user][:name])&.last

      if user.present?
        if user.valid_password?(params[:user][:password])
          sign_in(user)
          flash[:success] = "Logado com sucesso!"
          redirect_to root_path
        else
          flash[:error] = "Senha inválida."
          redirect_to user_session_path
        end
      else
        flash[:error] = "Usuário não encontrado."
        redirect_to user_session_path
      end
    else
      super
    end
  end

  def create
    super
  end

  def destroy
    sign_out current_user
    flash[:success] = "Deslogado com sucesso."
    redirect_to user_session_path
  end
end
