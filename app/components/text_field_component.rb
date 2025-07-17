# frozen_string_literal: true

class TextFieldComponent < ViewComponent::Base
  def initialize(form:, field_name:, type: nil, label: nil, data: nil, error_message: nil)
    @form = form
    @field_name = field_name
    @type = type
    @data = data

    format_date_field if @type.present? && @type == "date"

    @error_message = error_message
    @label = label
  end

  def format_date_field
    return unless @form.object.send(@field_name).present?

    @form.object.send(:"#{@field_name}=", @form.object.send(@field_name).strftime("%Y-%m-%d"))
  end
end
