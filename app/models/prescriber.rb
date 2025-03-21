class Prescriber < ApplicationRecord
  audited

  include PgSearch::Model

  belongs_to :representative, optional: true

  has_one :address, dependent: :destroy
  has_many :discounts, dependent: :destroy

  accepts_nested_attributes_for :address

  def full_address
    if address.present?
      "#{address.street} - #{address.number} - #{address.district} - #{address.city} - #{address.uf} - #{address.zip_code}"
    else
      "Address not available"
    end
  end
end
