class Prescriber < ApplicationRecord
  audited

  include PgSearch::Model
  include Roundable

  belongs_to :representative, optional: true

  has_one :address, dependent: :destroy

  has_many :current_accounts, dependent: :destroy
  has_many :monthly_reports, dependent: :destroy
  has_many :requests, dependent: :destroy

  accepts_nested_attributes_for :address
  accepts_nested_attributes_for :requests

  PROFESSIONAL_TYPES = {"CRM" => 1,
                        "CRO" => 2,
                        "CRN" => 9}

  scope :monthly_reports, ->(closing_id, representative_ids) {
    MonthlyReport.joins(:prescriber)
      .where(closing_id: closing_id, representative_id: representative_ids)
      .group(custom_group_sql)
      .select(custom_select_sql)
  }

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

  def full_contact
    return "Contato não cadastrado" unless address.present?

    [
      address.phone,
      address.cellphone
    ].compact.join(" - ")
  end

  def full_concil
    [class_council, uf_council, number_council].compact.join(" - ")
  end

  def ensure_address
    build_address unless address.present?
  end

  def discount_of_up_to
    if consider_discount_of_up_to == 0.0 || consider_discount_of_up_to.nil?
      12.0
    else
      consider_discount_of_up_to
    end
  end

  def to_boolean(accumulated)
    ActiveModel::Type::Boolean.new.cast(accumulated)
  end
end
