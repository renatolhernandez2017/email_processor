# frozen_string_literal: true

class ModalComponent < ViewComponent::Base
  def initialize(form:, btn_title:)
    @form = form
    @btn_title = btn_title
  end
end
