# frozen_string_literal: true

class PaginationComponent < ViewComponent::Base
  def initialize(pagy:, pages:)
    @pagy = pagy
    @pages = pages
  end
end
