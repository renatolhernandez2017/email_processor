# frozen_string_literal: true

class ActiveInactiveLinkComponent < ViewComponent::Base
  def initialize(current_account:, route:, prescriber_id: nil)
    @current_account = current_account
    @route = route
    @prescriber_id = prescriber_id
    set_more_informations
  end

  private

  def set_more_informations
    if @current_account.standard?
      @icon = "visibility"
      @title = "Desabilitar"
      @type = "desactive"
    else
      @icon = "visibility_off"
      @title = "Habilitar"
      @type = "active"
    end
  end
end
