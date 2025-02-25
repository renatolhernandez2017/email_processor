# frozen_string_literal: true

class TextFieldComponent < ViewComponent::Base
  def initialize(form:, field_name:, error_message: nil, type: nil, label: nil, data: nil, readonly: nil)
    @form = form
    @field_name = field_name
    @error_message = error_message
    @type = type
    @label = label || @form.object.class.human_attribute_name(@field_name)
    @data = data
    @readonly = readonly
  end
end
