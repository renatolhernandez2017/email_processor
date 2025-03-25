# frozen_string_literal: true

class ModalComponent < ViewComponent::Base
  def initialize(form:, btn_back: nil, prescriber_id: nil)
    @form = form
    @btn_back = btn_back.present? ? btn_back : "Voltar"
    @prescriber_id = prescriber_id
  end
end
