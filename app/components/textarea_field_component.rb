# frozen_string_literal: true

class TextareaFieldComponent < ViewComponent::Base
  def initialize(form:, field_name:, label: nil, error_message: nil)
    @form = form
    @field_name = field_name
    @label = label
    @error_message = error_message
  end
end
