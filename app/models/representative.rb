class Representative < ApplicationRecord
  audited

  include ActionView::Helpers::NumberHelper 
  include PgSearch::Model
  include Roundable

  belongs_to :branch, optional: true

  has_one :address, dependent: :destroy
  has_one :prescriber, dependent: :destroy

  has_many :current_accounts, dependent: :destroy
  has_many :monthly_reports, dependent: :destroy
  has_many :requests, dependent: :destroy

  scope :with_totals, ->(closing_id) {
    left_joins(monthly_reports: :prescriber)
      .includes(:prescriber)
      .joins(<<~SQL.squish)
        LEFT JOIN current_accounts ca_standard
          ON ca_standard.prescriber_id = monthly_reports.prescriber_id
          AND ca_standard.standard = TRUE
      SQL
      .where(active: true, monthly_reports: {closing_id: closing_id})
      .group("representatives.id, representatives.name")
      .select(
        "representatives.*",
        "COUNT(DISTINCT monthly_reports.id) AS reports_count",
        "SUM(monthly_reports.quantity) AS total_quantity",
        "SUM(monthly_reports.total_price) AS total_price",
        "SUM(monthly_reports.partnership) AS total_partnership",
        "SUM(monthly_reports.discounts) AS total_discounts",
        "SUM(CASE WHEN monthly_reports.accumulated = TRUE THEN 1 ELSE 0 END) AS accumulated_reports_count",
        "SUM(CASE WHEN monthly_reports.accumulated = TRUE THEN monthly_reports.quantity ELSE 0 END) AS accumulated_quantity",
        "SUM(CASE WHEN monthly_reports.accumulated = TRUE THEN monthly_reports.total_price ELSE 0 END) AS accumulated_price",
        "SUM(CASE WHEN monthly_reports.accumulated = TRUE THEN monthly_reports.partnership ELSE 0 END) AS accumulated_partnership",
        "SUM(CASE WHEN monthly_reports.accumulated = TRUE THEN monthly_reports.discounts ELSE 0 END) AS accumulated_discounts",
        "SUM(CASE WHEN monthly_reports.accumulated = FALSE THEN 1 ELSE 0 END) AS real_sale_reports_count",
        "SUM(CASE WHEN monthly_reports.accumulated = FALSE THEN monthly_reports.quantity ELSE 0 END) AS real_sale_quantity",
        "SUM(CASE WHEN monthly_reports.accumulated = FALSE THEN monthly_reports.total_price ELSE 0 END) AS real_sale_total_price",
        "SUM(CASE WHEN monthly_reports.accumulated = FALSE THEN monthly_reports.partnership ELSE 0 END) AS real_sale_partnership",
        "SUM(CASE WHEN monthly_reports.accumulated = FALSE THEN monthly_reports.discounts ELSE 0 END) AS real_sale_discounts",
        <<~SQL.squish,
          CASE
            WHEN SUM(monthly_reports.partnership) <= 0 THEN 0
            WHEN COUNT(ca_standard.id) > 0 THEN
              GREATEST(SUM(monthly_reports.partnership) - SUM(monthly_reports.discounts), 0)
            ELSE
              GREATEST(ROUND((SUM(monthly_reports.partnership) - SUM(monthly_reports.discounts)) / 10.0) * 10, 0)
          END AS with_available_value
        SQL
        <<~SQL.squish,
          CASE
            WHEN SUM(CASE WHEN monthly_reports.accumulated = TRUE THEN monthly_reports.partnership ELSE 0 END) <= 0 THEN 0
            WHEN COUNT(CASE WHEN monthly_reports.accumulated = TRUE AND ca_standard.id IS NOT NULL THEN 1 END) > 0 THEN
              GREATEST(
                SUM(CASE WHEN monthly_reports.accumulated = TRUE THEN monthly_reports.partnership - monthly_reports.discounts ELSE 0 END), 0
              )
            ELSE
              GREATEST(ROUND((SUM(CASE WHEN monthly_reports.accumulated = TRUE THEN monthly_reports.partnership - monthly_reports.discounts ELSE 0 END)) / 10.0) * 10, 0)
          END AS available_value_accumulated
        SQL
        <<~SQL.squish
          CASE
            WHEN SUM(CASE WHEN monthly_reports.accumulated = FALSE THEN monthly_reports.partnership ELSE 0 END) <= 0 THEN 0
            WHEN COUNT(CASE WHEN monthly_reports.accumulated = FALSE AND ca_standard.id IS NOT NULL THEN 1 END) > 0 THEN
              GREATEST(
                SUM(CASE WHEN monthly_reports.accumulated = FALSE THEN monthly_reports.partnership - monthly_reports.discounts ELSE 0 END), 0
              )
            ELSE
              GREATEST(ROUND((SUM(CASE WHEN monthly_reports.accumulated = FALSE THEN monthly_reports.partnership - monthly_reports.discounts ELSE 0 END)) / 10.0) * 10, 0)
          END AS available_value_real_sale
        SQL
      )
      .order("representatives.name ASC")
  }

  scope :totals_by_bank_for_representatives, ->(closing_id, representative_ids) {
    MonthlyReport.joins(prescriber: [:representative, {current_accounts: :bank}])
      .where(closing_id: closing_id, accumulated: false, representative_id: representative_ids)
      .group("representatives.id, banks.name")
      .select(
        "representatives.id AS representative_id",
        "banks.name AS bank_name",
        "COUNT(monthly_reports.id) AS count",
        "SUM(monthly_reports.partnership - monthly_reports.discounts) AS total"
      )
  }

  scope :totals_by_store_for_representatives, ->(closing_id, representative_ids) {
    Request.joins(:monthly_report, :prescriber, :representative, :branch)
      .where("monthly_reports.closing_id = ? AND monthly_reports.accumulated = ?", closing_id, false)
      .where(representative_id: representative_ids)
      .group("representatives.id, branches.name")
      .select(
        "representatives.id AS representative_id",
        "branches.name AS branch_name",
        "COUNT(DISTINCT requests.id) AS count",
        "SUM(requests.amount_received) AS total"
      )
  }

  scope :total_cash_for_representatives, ->(closing_id, representative_ids) {
    MonthlyReport.joins(prescriber: {current_accounts: :bank})
      .joins(<<~SQL.squish)
        LEFT JOIN current_accounts ca_standard
          ON ca_standard.prescriber_id = monthly_reports.prescriber_id
          AND ca_standard.standard = TRUE
      SQL
      .where(closing_id: closing_id, accumulated: false, representative_id: representative_ids)
      .select(<<~SQL.squish)
        CASE
          WHEN SUM(monthly_reports.partnership) <= 0 THEN 0
          WHEN COUNT(ca_standard.id) > 0 THEN
            GREATEST(SUM(monthly_reports.partnership) - SUM(monthly_reports.discounts), 0)
          ELSE
            GREATEST(ROUND((SUM(monthly_reports.partnership) - SUM(monthly_reports.discounts)) / 10.0) * 10, 0)
        END  AS total_available_value
      SQL
  }

  scope :monthly_reports_for_representatives, ->(closing_id, representative_ids) {
    MonthlyReport.joins(:prescriber)
      .where(closing_id: closing_id, accumulated: false, representative_id: representative_ids)
      .group(
        <<~SQL.squish
          monthly_reports.prescriber_id,
          CASE
            WHEN monthly_reports.accumulated = true THEN 'A'
            WHEN EXISTS (
              SELECT 1 FROM current_accounts
              WHERE current_accounts.prescriber_id = monthly_reports.prescriber_id
                AND current_accounts.standard = TRUE
            ) THEN 'D'
            ELSE 'E'
          END,
          CASE
            WHEN monthly_reports.partnership <= 0 THEN 0
            WHEN EXISTS (
              SELECT 1 FROM current_accounts
              WHERE current_accounts.prescriber_id = monthly_reports.prescriber_id
                AND current_accounts.standard = TRUE
            ) THEN GREATEST(monthly_reports.partnership - monthly_reports.discounts, 0)
            ELSE GREATEST(
              CASE 
                WHEN MOD((monthly_reports.partnership - monthly_reports.discounts), 10.0) > 5.0
                  THEN (monthly_reports.partnership - monthly_reports.discounts) - MOD((monthly_reports.partnership - monthly_reports.discounts), 10.0) + 10
                ELSE (monthly_reports.partnership - monthly_reports.discounts) - MOD((monthly_reports.partnership - monthly_reports.discounts), 10.0)
              END, 0)
          END
        SQL
      )
      .select(
        <<~SQL.squish
          monthly_reports.prescriber_id,
          MIN(LPAD(CAST(monthly_reports.envelope_number AS TEXT), 6, '0')) AS number_envelope,
          SUM(monthly_reports.quantity) AS quantity,
          CASE
            WHEN monthly_reports.accumulated = true THEN 'A'
            WHEN EXISTS (
              SELECT 1 FROM current_accounts
              WHERE current_accounts.prescriber_id = monthly_reports.prescriber_id
                AND current_accounts.standard = TRUE
            ) THEN 'D'
            ELSE 'E'
          END AS situation,
          CASE 
            WHEN monthly_reports.partnership <= 0 THEN 0
            WHEN EXISTS (
              SELECT 1 FROM current_accounts 
              WHERE current_accounts.prescriber_id = monthly_reports.prescriber_id 
                AND current_accounts.standard = TRUE
            ) THEN GREATEST(monthly_reports.partnership - monthly_reports.discounts, 0)
            ELSE GREATEST(
              CASE 
                WHEN MOD((monthly_reports.partnership - monthly_reports.discounts), 10.0) > 5.0
                  THEN (monthly_reports.partnership - monthly_reports.discounts) - MOD((monthly_reports.partnership - monthly_reports.discounts), 10.0) + 10
                ELSE (monthly_reports.partnership - monthly_reports.discounts) - MOD((monthly_reports.partnership - monthly_reports.discounts), 10.0)
              END, 0)
          END AS with_available_value
        SQL
      )
  }

  def self.get_representatives(closing_id, id = nil, joins_associations)
    scope = joins(joins_associations).where("monthly_reports.closing_id = ? AND active = ?", closing_id, true)

    if id.present?
      [scope.find(id)]
    else
      scope.all
    end
  end

  # def totals_by_bank(closing_id)
  #   monthly_reports.joins(prescriber: {current_accounts: :bank})
  #     .where(closing_id: closing_id, accumulated: false)
  #     .group("banks.name")
  #     .select("banks.name AS name, COUNT(monthly_reports.id) AS count, SUM(monthly_reports.partnership - monthly_reports.discounts) AS total")
  # end

  # def totals_by_store(closing_id)
  #   monthly_reports
  #     .joins(:requests, prescriber: {representative: :branch})
  #     .where(closing_id: closing_id, accumulated: false)
  #     .group("branches.name")
  #     .select("branches.name AS name", "COUNT(requests.id) AS count", "SUM(requests.amount_received) AS total")
  # end

  # def total_cash(closing_id)
  #   monthly_reports.joins(prescriber: {current_accounts: :bank})
  #     .where(closing_id: closing_id, accumulated: false)
  #     .map { |mr| divide_into_notes(mr.available_value.to_f) }
  #     .each_with_object(Hash.new(0)) { |hash, sums|
  #     hash.each { |key, value| sums[key] += value }
  #   }
  # end

  # def set_monthly_reports(closing_id)
  # end
end
