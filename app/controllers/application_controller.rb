class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :get_current_closing

  private

  def get_current_closing
    @current_closing = Closing.find_by(active: true)
  end
end
