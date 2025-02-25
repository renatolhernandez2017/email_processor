# frozen_string_literal: true

class ButtonComponentPreview < ViewComponent::Preview
  def default
    render ButtonComponent.new(icon_name: "add", title: "Titulo", onclick: "modal_accounts_filter")
  end
end
