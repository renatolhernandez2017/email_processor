# frozen_string_literal: true

class CheckboxFieldComponent < ViewComponent::Base
  def initialize(form:, field_name:, label: nil, error_message: nil)
    @form = form
    @field_name = field_name
    @label = label || @form.object.class.human_attribute_name(@field_name)
    @error_message = error_message
  end
end
