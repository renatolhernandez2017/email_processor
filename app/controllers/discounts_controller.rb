class DiscountsController < ApplicationController
  include Pagy::Backend

  def index
    @pagy, @discounts = pagy(Discount.all.order(created_at: :desc))
  end
end
