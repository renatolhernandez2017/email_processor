# frozen_string_literal: true

class BoxGroupHozirontalComponent < ViewComponent::Base
  def initialize(label:, field_name:)
    @label = label
    @field_name = field_name
  end
end
