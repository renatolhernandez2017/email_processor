class Prescriber < ApplicationRecord
  audited

  include PgSearch::Model

  belongs_to :representative, optional: true

  has_one :address, dependent: :destroy

  has_many :discounts, dependent: :destroy
  has_many :current_accounts, dependent: :destroy
  has_many :monthly_reports, dependent: :destroy

  accepts_nested_attributes_for :address

  PROFESSIONAL_TYPES = {"CRM" => 1,
                        "CRO" => 2,
                        "CRN" => 9}

  def full_address
    return "Endereço não cadastrado" unless address.present?

    [
      address.street,
      address.number,
      address.district,
      address.city,
      address.uf,
      address.zip_code
    ].compact.join(" - ")
  end

  def full_concil
    [class_council, uf_council, number_council].compact.join(" - ")
  end

  def ensure_address
    super || build_address unless address.present?
  end

  def discount_of_up_to
    if consider_discount_of_up_to == 0.0 || consider_discount_of_up_to.nil?
      15.0
    else
      consider_discount_of_up_to
    end
  end
end
