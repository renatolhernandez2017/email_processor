# frozen_string_literal: true

class BoxGroupHozirontalComponent < ViewComponent::Base
  def initialize(label:, field_name:)
    @label = label
    @field_name = format_field_name(label, field_name)
  end

  private

  def format_field_name(label, field_name)
    special_labels = ["Parceria", "Repetições", "Desconto", "Considera desconto de até"]
    special_labels.include?(label) ? "#{field_name} %" : field_name
  end
end
