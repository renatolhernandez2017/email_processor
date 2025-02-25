# frozen_string_literal: true

class RadiobuttonFieldComponentPreview < ViewComponent::Preview
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::UrlHelper

  def default
    # Uma forma de realizar isso é usar o `capture do` para capturar a saída do bloco
    # form_with(model: Question.new) do |f|
    #   Question::CATEGORIES.each_with_index do |category, index|
    #     render RadiobuttonFieldComponent.new(form: f, field_name: :category, label: category, index: index, error_message: question.errors.messages[:category])
    #   end
    # end
  end
end
