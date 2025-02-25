class HomeController < ApplicationController
  include Pagy::Backend

  before_action :authenticate_user!

  def index
  end
end
