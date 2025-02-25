# frozen_string_literal: true

class ButtonsCartComponent < ViewComponent::Base
  def initialize(label: nil, url: nil, method: nil, id: nil, data: nil)
    @label = label
    @url = url
    @method = method
    @id = id
    @data = data
  end
end
