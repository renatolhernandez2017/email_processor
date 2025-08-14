# frozen_string_literal: true

class ButtonLinkComponent < ViewComponent::Base
  def initialize(label:, url:)
    @label = label
    @url = url
  end
end
