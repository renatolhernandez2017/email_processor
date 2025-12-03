class ApplicationController < ActionController::Base
  # before_action :authenticate_user!

  protected

  def turbo_redirect_back(fallback_location:)
    redirect_target = request.referer || fallback_location
    render turbo_stream: turbo_stream.action(:redirect, redirect_target)
  end
end
