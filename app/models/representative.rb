class Representative < ApplicationRecord
  audited

  include PgSearch::Model
  include Roundable
  # include LoadMonthlyReports
  include ActionView::Helpers::NumberHelper

  belongs_to :branch, optional: true

  has_one :address, dependent: :destroy
  has_one :prescriber, dependent: :destroy

  has_many :current_accounts, dependent: :destroy
  has_many :monthly_reports, dependent: :destroy
  has_many :requests, dependent: :destroy

  def self.get_representatives(closing_id, id, joins_associations)
    Representative.joins(joins_associations)
      .where("monthly_reports.closing_id = ?", closing_id)
      .find(id)
  end

  def calculate_totals(monthly_reports)
    {
      count: monthly_reports.count,
      quantity: monthly_reports.sum(&:quantity),
      total_price: number_to_currency(monthly_reports.sum(&:total_price)),
      partnership: number_to_currency(monthly_reports.sum(&:partnership)),
      discounts: number_to_currency(monthly_reports.sum(&:discounts)),
      available_value: number_to_currency(monthly_reports.sum(&:available_value))
    }
  end

  def real_sale(all, accumulated)
    {
      count: all.size - accumulated.size,
      **calculate_differences(all, accumulated)
    }
  end

  def calculate_differences(monthly_reports, accumulated)
    {
      quantity: monthly_reports.sum(&:quantity) - accumulated.sum(&:quantity),
      total_price: number_to_currency(monthly_reports.sum(&:total_price) - accumulated.sum(&:total_price)),
      partnership: number_to_currency(monthly_reports.sum(&:partnership) - accumulated.sum(&:partnership)),
      discounts: number_to_currency(monthly_reports.sum(&:discounts) - accumulated.sum(&:discounts)),
      available_value: number_to_currency(monthly_reports.sum(&:available_value) - accumulated.sum(&:available_value))
    }
  end

  def totals_by_bank(closing_id)
    monthly_reports.joins(prescriber: {current_accounts: :bank})
      .where(closing_id: closing_id, accumulated: false)
      .group("banks.name")
      .select("banks.name AS name, COUNT(monthly_reports.id) AS count, SUM(monthly_reports.partnership - monthly_reports.discounts) AS total")
  end

  def totals_by_store(closing_id)
    monthly_reports
      .joins(:requests, prescriber: {representative: :branch})
      .where(closing_id: closing_id, accumulated: false)
      .group("branches.name")
      .select("branches.name AS name", "COUNT(requests.id) AS count", "SUM(requests.amount_received) AS total")
  end

  def total_cash(closing_id)
    monthly_reports.joins(prescriber: {current_accounts: :bank})
      .where(closing_id: closing_id, accumulated: false)
      .map { |mr| divide_into_notes(mr.available_value.to_f) }
      .each_with_object(Hash.new(0)) { |hash, sums|
      hash.each { |key, value| sums[key] += value }
    }
  end

  def set_monthly_reports(closing_id)
    # grouped = monthly_reports.where(closing_id: closing_id, accumulated: false)
    #   .group_by { |report| [report.envelope_number, report.situation] }

    # grouped.map do |info, reports|
    #   {
    #     envelope_number: info[0].to_s.rjust(5, "0"),
    #     situation: info[1],
    #     monthly_reports: reports,
    #     quantity: reports.sum { |m| m.requests.size },
    #     available_value: reports.sum(&:available_value)
    #   }

    monthly_reports
      .select(<<~SQL)
        monthly_reports.id,
        monthly_reports.prescriber_id,
        monthly_reports.envelope_number,
        monthly_reports.accumulated,
        CASE
          WHEN monthly_reports.accumulated = true THEN 'A'
          WHEN EXISTS (
            SELECT 1 FROM current_accounts
            WHERE current_accounts.prescriber_id = monthly_reports.prescriber_id
            AND current_accounts.standard = TRUE
          ) THEN 'D'
          ELSE 'E'
        END AS situation
      SQL
      .where(accumulated: false)
      .group(<<~SQL)
        monthly_reports.id,
        monthly_reports.envelope_number,
        monthly_reports.accumulated, -- e aqui também
        CASE
          WHEN monthly_reports.accumulated = true THEN 'A'
          WHEN EXISTS (
            SELECT 1 FROM current_accounts
            WHERE current_accounts.prescriber_id = monthly_reports.prescriber_id
            AND current_accounts.standard = TRUE
          ) THEN 'D'
          ELSE 'E'
        END
      SQL
      # .map do |report|
      #   {
      #     envelope_number: report.envelope_number.to_s.rjust(5, "0"),
      #     situation: report.situation,
      #     monthly_report: monthly_reports.find(report.id),
      #     quantity: monthly_reports.find(report.id).quantity,
      #     available_value: monthly_reports.find(report.id).available_value
      #   }
      # end
  end
end
