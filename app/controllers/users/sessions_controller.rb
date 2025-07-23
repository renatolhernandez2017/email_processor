# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  def new
    if params[:user].present?
      user = User.search_global(params[:user][:name])&.last

      if user.present?
        if user.valid_password?(params[:user][:password])
          sign_in(user)
          flash[:success] = "Logado com sucesso!"
          render turbo_stream: turbo_stream.action(:redirect, root_path)
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
    super do |resource|
      return render turbo_stream: turbo_stream.redirect(after_sign_in_path_for(resource)) if turbo_frame_request?

      # Para forçar renderização HTML completa
      response.set_header("Turbo-Frame", "false")
    end
  end

  def destroy
    sign_out current_user
    flash[:success] = "Deslogado com sucesso."

    redirect_to user_session_path(status: "Deslogado")
  end
end
