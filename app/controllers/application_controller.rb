class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :set_current_closing

  private

  def set_current_closing
    @current_closing = Closing.find_by(active: true)
  end

  protected

  def turbo_redirect_back(fallback_location:)
    redirect_target = request.referer || fallback_location
    render turbo_stream: turbo_stream.action(:redirect, redirect_target)
  end
end
