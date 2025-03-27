module ApplicationHelper
  include Pagy::Frontend

  def formatted_percentage(value)
    number_to_percentage(value, precision: 2)
  end
end
