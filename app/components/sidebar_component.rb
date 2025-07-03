# frozen_string_literal: true

class SidebarComponent < ViewComponent::Base
  def initialize(label:, url:, subtitle:, method_http: nil)
    @label = label
    @url = url
    @subtitle = subtitle
    @method_http = method_http
  end
end
