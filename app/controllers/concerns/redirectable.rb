module Redirectable
  extend ActiveSupport::Concern

  included do
    before_action :set_route, :get_table, only: %i[create update show change_standard destroy]
  end

  private

  def set_route
    @route = params[:route]
  end

  def get_table
    return unless params[:route] == "prescriber"

    @id = params.dig(:prescriber_id) ||
          params.dig(:current_accounts, :prescriber_id) ||
          params.dig(:discount, :prescriber_id)

    @table = Prescriber.find(@id) if @id.present?
  end

  def render_redirect
    path = @table.present? ? send(:"#{@route}_path", @table) : send(:"#{@route.pluralize}_path")
    render turbo_stream: turbo_stream.action(:redirect, path)
  end
end
