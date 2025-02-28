class OfficesController < ApplicationController
  include Pagy::Backend

  def index
    @pagy, @offices = nil
  end
end
