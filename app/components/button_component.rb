# frozen_string_literal: true

class ButtonComponent < ViewComponent::Base
  def initialize(form:, label:)
    @form = form
    @label = label
  end
end
