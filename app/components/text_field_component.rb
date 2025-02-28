# frozen_string_literal: true

class TextFieldComponent < ViewComponent::Base
  def initialize(form:, field_name:, type: nil, error_message: nil, label: nil)
    @form = form
    @field_name = field_name
    @type = type

    format_date_field if @type.present? && @type == "date"

    @error_message = error_message
    @label = label
  end

  def format_date_field
    return unless @form.object.send(@field_name).present?

    @form.object.send(:"#{@field_name}=", @form.object.send(@field_name).strftime("%Y-%m-%d"))
  end

  # def human_attribute_name_for_string(attribute_string)
  #   return unless attribute_string.present?

  #   model, attribute = attribute_string.split(".")
  #   I18n.t("activerecord.attributes.#{model}.#{attribute}", default: attribute.humanize)
  # end
end
