# frozen_string_literal: true

class SidebarComponent < ViewComponent::Base
  def initialize(label:, url:, subtitle:)
    @label = label
    @url = url
    @subtitle = subtitle
  end
end
