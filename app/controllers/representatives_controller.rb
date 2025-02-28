class RepresentativesController < ApplicationController
  include Pagy::Backend

  def index
    @pagy, @representatives = nil
  end
end
