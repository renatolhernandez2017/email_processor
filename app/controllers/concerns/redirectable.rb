module Redirectable
  extend ActiveSupport::Concern

  included do
    before_action :set_route, only: %i[create update change_standard destroy]
  end

  private

  def set_route
    @route_name = params[:route_name]
  end

  def render_redirect
    if @route_name.present?
      render turbo_stream: turbo_stream.action(:redirect, send(:"#{@route_name.pluralize}_path"))
    else
      render turbo_stream: turbo_stream.action(:redirect, current_accounts_path)
    end
  end
end
