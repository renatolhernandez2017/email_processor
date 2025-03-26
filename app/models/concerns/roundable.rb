module Roundable
  extend ActiveSupport::Concern

  def round
    decimal = self - to_i

    return to_i.to_f if decimal <= 0.25
    return to_i.to_f + 0.5 if decimal <= 0.75

    to_i.to_f + 1
  end

  def round_to_ten
    resto = self % 10.0
    self - resto + ((resto > 5.0) ? 10 : 0)
  end

  def divide_into_notes
    valor = to_i
    notas = [50, 20, 10]

    notas.each_with_object({}) do |nota, resultado|
      resultado[nota] = valor / nota
      valor %= nota
    end
  end
end
