# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
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

  # POST /resource/sign_in
  def create
    super
  end

  # DELETE /resource/sign_out
  def destroy
    sign_out current_user
    redirect_to user_session_path, notice: "Signed out successfully."
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
