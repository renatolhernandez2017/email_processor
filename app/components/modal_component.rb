# frozen_string_literal: true

class ModalComponent < ViewComponent::Base
  def initialize(form:, btn_back: nil)
    @form = form
    @btn_back = btn_back.present? ? btn_back : "Voltar"
  end
end
