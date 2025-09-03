# frozen_string_literal: true

class ButtonLinkComponent < ViewComponent::Base
  def initialize(label:, url:, target: nil)
    @label = label
    @url = url
    @target = target
  end
end
