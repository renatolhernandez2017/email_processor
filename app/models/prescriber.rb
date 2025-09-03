class Prescriber < ApplicationRecord
  audited

  include PgSearch::Model
  include Prescriber::Aggregations

  belongs_to :representative, optional: true

  has_one :address, dependent: :destroy

  has_many :current_accounts, dependent: :destroy
  has_many :monthly_reports, dependent: :destroy
  has_many :requests, dependent: :destroy

  has_many :banks, through: :current_accounts
  has_many :branches, through: :representative

  accepts_nested_attributes_for :address
  accepts_nested_attributes_for :requests

  pg_search_scope :search_global,
    against: [:id, :name, :number_council],
    using: {
      tsearch: {
        prefix: true,
        any_word: false, # Busca qualquer palavra do nome de estiver como true
        dictionary: "portuguese"
      }
    },
    order_within_rank: "name",
    ignoring: :accents

  PROFESSIONAL_TYPES = {"CRM" => 1,
                        "CRO" => 2,
                        "CRN" => 9}

  scope :with_totals, ->(closing_id, filter = nil) {
    joins(<<~SQL)
      LEFT JOIN monthly_reports
        ON monthly_reports.prescriber_id = prescribers.id
        AND monthly_reports.closing_id = #{closing_id.to_i}
    SQL
      .then { |rel|
        case filter
        when "accumulated"
          rel.where("monthly_reports.accumulated = ? OR monthly_reports.id IS NULL", true)
        when "unaccumulated"
          rel.where("monthly_reports.accumulated = ?", false)
        else
          rel
        end
      }
      .select(custom_select_sql)
      .group("prescribers.id")
      .order("prescribers.name ASC")
  }

  scope :totals_by_bank_for_representatives, ->(closing_id, filter = nil) {
    joins(current_accounts: :bank)
      .joins(<<~SQL)
        LEFT JOIN monthly_reports
          ON monthly_reports.prescriber_id = prescribers.id
        AND monthly_reports.closing_id = #{closing_id.to_i}
      SQL
      .then { |rel|
        case filter
        when "accumulated"
          rel.where("monthly_reports.accumulated = ? OR monthly_reports.id IS NULL", true)
        when "unaccumulated"
          rel.where("monthly_reports.accumulated = ?", false)
        else
          rel
        end
      }
      .group("banks.name")
      .select(
        "banks.name AS bank_name",
        "COUNT(DISTINCT monthly_reports.id) AS count",
        "COALESCE(SUM(DISTINCT monthly_reports.partnership - monthly_reports.discounts), 0) AS total",
        # Totais gerais usando janela
        "SUM(COUNT(DISTINCT monthly_reports.id)) OVER () AS total_count",
        "SUM(COALESCE(SUM(DISTINCT monthly_reports.partnership - monthly_reports.discounts), 0)) OVER () AS total_price"
      )
  }

  scope :totals_by_store_for_representatives, ->(closing_id, filter = nil) {
    joins(requests: :branch)
      .joins(<<~SQL)
        LEFT JOIN monthly_reports
          ON monthly_reports.prescriber_id = prescribers.id
        AND monthly_reports.closing_id = #{closing_id.to_i}
      SQL
      .where("monthly_reports.closing_id = ?", closing_id)
      .then { |rel|
        case filter
        when "accumulated"
          rel.where("monthly_reports.accumulated = ? OR monthly_reports.id IS NULL", true)
        when "unaccumulated"
          rel.where("monthly_reports.accumulated = ?", false)
        else
          rel
        end
      }
      .group("branches.name")
      .select(
        "branches.name AS branch_name",
        "COUNT(requests.id) AS count",
        "COALESCE(SUM(requests.amount_received), 0) AS total",
        # Totais gerais usando janela
        "SUM(COUNT(requests.id)) OVER () AS total_count",
        "SUM(SUM(requests.amount_received)) OVER () AS total_price"
      )
  }

  def situation
    current_account = current_accounts.find_by(standard: true)
    monthly_report = monthly_reports.last

    if monthly_report.present?
      if monthly_report.accumulated?
        "A"
      elsif !monthly_report.accumulated? && !current_account.nil?
        "D"
      else
        "E"
      end
    else
      "E"
    end
  end

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

  def self.get_totals(prescriber)
    {
      count: prescriber&.total_count,
      quantity: prescriber&.total_quantity,
      price: prescriber&.total_price,
      partnership: prescriber&.total_partnership,
      discounts: prescriber&.total_discounts,
      available_value: prescriber&.total_available_value,

      accumulated: {
        count: prescriber&.accumulated_total_count,
        quantity: prescriber&.accumulated_total_quantity,
        price: prescriber&.accumulated_total_price,
        partnership: prescriber&.accumulated_total_partnership,
        discounts: prescriber&.accumulated_total_discounts,
        available_value: prescriber&.accumulated_total_available_value
      },
      real_sale: {
        count: prescriber&.real_sale_total_count,
        quantity: prescriber&.real_sale_total_quantity,
        price: prescriber&.real_sale_total_price,
        partnership: prescriber&.real_sale_total_partnership,
        discounts: prescriber&.real_sale_total_discounts,
        available_value: prescriber&.real_sale_total_available_value
      }
    }
  end

  def self.totals_by_bank_store(totals)
    if totals.present?
      new_totals = totals.first

      {
        total_count: new_totals.total_count.to_i,
        total_price: new_totals.total_price.to_f
      }
    else
      {
        total_count: 0.0,
        total_price: 0.0
      }
    end
  end
end
