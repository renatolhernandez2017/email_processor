# frozen_string_literal: true

class ButtonComponent < ViewComponent::Base
  def initialize(form:, label:, classes: nil, id: nil)
    @form = form
    @label = label || @form.object.class.human_attribute_name(@field_name)
    @classes = classes
    @id = id
  end
end
