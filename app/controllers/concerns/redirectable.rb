module Redirectable
  extend ActiveSupport::Concern

  included do
    before_action :set_route, only: %i[create update change_standard destroy]
  end

  private

  def set_route
    @route = params[:route]
  end

  def render_redirect
    render turbo_stream: turbo_stream.action(:redirect, send(:"#{@route.pluralize}_path"))
  end
end
