# frozen_string_literal: true

class MobileFieldComponent < ViewComponent::Base
  def initialize(form:, field_name:, error_message: nil, label: nil, placeholder: nil, data: nil, readonly: nil, id: nil, oninput: nil)
    @form = form
    @field_name = field_name
    @error_message = error_message
    @label = label || @form.object.class.human_attribute_name(@field_name)
    @placeholder = placeholder
    @data = data
    @readonly = readonly
    @id = id
    @oninput = oninput
  end
end
