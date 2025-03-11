class Prescriber < ApplicationRecord
  audited

  include PgSearch::Model

  belongs_to :representative, optional: true

  def address
    representative&.address
  end

  def full_address
    return "Sem endereço" unless representative&.address

    "#{representative.address.street} - #{representative.address.district} - #{representative.address.city} - #{representative.address.uf} - #{representative.address.zip_code}"
  end
end
