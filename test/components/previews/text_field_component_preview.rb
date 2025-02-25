# frozen_string_literal: true

class TextFieldComponentPreview < ViewComponent::Preview
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::UrlHelper

  def default
    # Uma forma de realizar isso é usar o `capture do` para capturar a saída do bloco
    form_with(model: Contact.new) do |form|
      # render(TextFieldComponent.new(form: form, error_message: nil))
    end
  end
end
