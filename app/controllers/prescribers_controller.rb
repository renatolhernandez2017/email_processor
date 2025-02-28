class PrescribersController < ApplicationController
  include Pagy::Backend

  def index
    @pagy, @prescribers = nil
  end
end
