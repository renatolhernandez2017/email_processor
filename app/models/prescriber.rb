class Prescriber < ApplicationRecord
  audited

  include PgSearch::Model

  belongs_to :representative, optional: true

  has_many :discounts, dependent: :destroy

  accepts_nested_attributes_for :representative

  def address
    representative&.address
  end

  def full_address
    return "Sem endereço" unless representative&.address

    "#{representative.address&.street} - #{representative.address&.district} - #{representative.address&.city} - #{representative.address&.uf} - #{representative.address&.zip_code}"
  end
end
