class DiscountsController < ApplicationController
  include Pagy::Backend

  def index
    @pagy, @discounts = nil
  end
end
