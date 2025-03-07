class BranchesController < ApplicationController
  include Pagy::Backend

  def index
    @pagy, @branches = nil
  end
end
