class PrescribersController < ApplicationController
  include Pagy::Backend

  def index
    @pagy, @closings = pagy(Closing.all.order(start_date: :desc))
  end
end
