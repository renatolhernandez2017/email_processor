class CustomersController < ApplicationController
  include Pagy::Backend

  def index
    @pagy, @customers = pagy(Customer.order(created_at: :desc))
  end
end
