class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :set_current_closing

  private

  def set_current_closing
    @current_closing = Closing.find_by(active: true)
  end
end
