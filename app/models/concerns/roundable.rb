module Roundable
  extend ActiveSupport::Concern

  def divide_into_notes(value)
    price = value.to_i
    money_notes = [50, 20, 10]

    money_notes.each_with_object({}) do |money_note, result|
      result[money_note] = price / money_note
      price %= money_note
    end
  end
end
