# frozen_string_literal: true

class SelectFieldComponent < ViewComponent::Base
  def initialize(form:, field_name:, options: {}, label: nil, error_message: nil)
    @form = form
    @field_name = field_name
    @options = options
    @label = label || @form.object.class.human_attribute_name(@field_name)
    @error_message = error_message
    @selected = @form.object.send(@field_name)
  end
end
