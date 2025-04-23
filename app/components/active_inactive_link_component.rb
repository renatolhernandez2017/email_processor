# frozen_string_literal: true

class ActiveInactiveLinkComponent < ViewComponent::Base
  def initialize(route:, url:, current_account: nil, prescriber_id: nil, representative: nil)
    @current_account = current_account
    @route = route
    @prescriber_id = prescriber_id
    @representative = representative

    set_more_current_account
    set_more_representative
    set_url(url)
  end

  private

  def set_url(url)
    if @current_account.present?
      @url = url + "?type=#{@type}&route=#{@route}&prescriber_id=#{@prescriber_id}"
    elsif @representative.present?
      @url = url + "?type=#{@type}&route=#{@route}"
    end
  end

  def set_more_current_account
    return unless @current_account.present?

    set_icon_title_and_type(@current_account.standard?)
  end

  def set_more_representative
    return unless @representative.present?

    set_icon_title_and_type(@representative.active?)
  end

  def set_icon_title_and_type(condition)
    if condition
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
