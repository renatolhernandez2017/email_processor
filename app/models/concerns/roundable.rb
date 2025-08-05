module Roundable
  extend ActiveSupport::Concern

  def round
    decimal = self - to_i

    return to_i.to_f if decimal <= 0.25
    return to_i.to_f + 0.5 if decimal <= 0.75

    to_i.to_f + 1
  end

  def round_to_ten(value)
    rest = value % 10.0
    value - rest + ((rest > 5.0) ? 10 : 0)
  end

  def divide_into_notes(value)
    price = value.to_i
    money_notes = [50, 20, 10]

    money_notes.each_with_object({}) do |money_note, result|
      result[money_note] = price / money_note
      price %= money_note
    end
  end
end
