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

  PROFESSIONAL_TYPES = {"CRM" => 1,
                        "CRO" => 2,
                        "CRN" => 9}

  scope :with_totals, ->(closing_id, representative_ids) {
    where(representative_id: representative_ids)
      .joins(<<~SQL)
        LEFT JOIN monthly_reports
          ON monthly_reports.prescriber_id = prescribers.id
          AND monthly_reports.closing_id = #{closing_id.to_i}
    SQL
      .select(custom_select_sql)
      .group("prescribers.id")
      .order("prescribers.name ASC")
  }

  scope :totals_by_bank_for_representatives, ->(closing_id, representative_ids) {
    # Subselect para pegar os relatórios já filtrados
    monthly_reports_subquery = MonthlyReport
      .where(closing_id: closing_id)
      .select(:id, :prescriber_id, :partnership, :discounts)
      .to_sql

    where(representative_id: representative_ids)
      .joins(current_accounts: :bank)
      .joins("LEFT JOIN (#{monthly_reports_subquery}) AS filtered_reports ON filtered_reports.prescriber_id = prescribers.id")
      .group("prescribers.id, banks.name")
      .select(
        "banks.name AS bank_name",
        "COUNT(DISTINCT filtered_reports.id) AS count",
        "COALESCE(SUM(DISTINCT filtered_reports.partnership - filtered_reports.discounts), 0) AS total",
        # Totais gerais usando janela (window function)
        "SUM(COUNT(DISTINCT filtered_reports.id)) OVER () AS total_count",
        "SUM(COALESCE(SUM(DISTINCT filtered_reports.partnership - filtered_reports.discounts), 0)) OVER () AS total_price"
      )
      .group_by(&:bank_name)
  }

  scope :totals_by_store_for_representatives, ->(closing_id, representative_ids) {
    Request.joins(:monthly_report, :branch)
      .where(representative_id: representative_ids)
      .where("monthly_reports.accumulated = ? AND monthly_reports.closing_id = ?", false, closing_id)
      .group("branches.name")
      .select(
        "branches.name AS branch_name",
        "COUNT(requests.id) AS count",
        "SUM(requests.amount_received) AS total",
        # Totais gerais usando janela (window function)
        "SUM(COUNT(requests.id)) OVER () AS total_count",
        "SUM(COALESCE(SUM(requests.amount_received), 0)) OVER () AS total_price"
      )
      .group_by(&:branch_name)
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
    return unless totals.present?

    new_totals = totals.last.last

    {
      total_count: new_totals.total_count.to_i,
      total_price: new_totals.total_price.to_f
    }
  end
end
