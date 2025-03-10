class PrescribersController < ApplicationController
  include Pagy::Backend

  def index
    @pagy, @prescribers = pagy(Prescriber.all.order(created_at: :desc))
  end
end
