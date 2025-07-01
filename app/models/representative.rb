class Representative < ApplicationRecord
  audited

  include PgSearch::Model
  include Roundable
  # include LoadMonthlyReports

  belongs_to :branch, optional: true

  has_one :address, dependent: :destroy
  has_one :prescriber, dependent: :destroy

  has_many :current_accounts, dependent: :destroy
  has_many :monthly_reports, dependent: :destroy
  has_many :requests, dependent: :destroy

  def load_monthly_reports(closing_id, eager_load = [])
    scoped_monthly_reports(closing_id, eager_load)
  end

  def monthly_reports_false(closing_id, eager_load = [])
    scoped_monthly_reports(closing_id, eager_load).where(accumulated: false)
  end

  def totals_by_bank(monthly_reports)
    monthly_reports.joins(prescriber: {current_accounts: :bank})
      .where(accumulated: false)
      .group("banks.name")
      .select("banks.name AS name, COUNT(monthly_reports.id) AS count, SUM(monthly_reports.partnership - monthly_reports.discounts) AS total")
  end

  def totals_by_store(monthly_reports)
    monthly_reports.joins(:requests, prescriber: {representative: :branch})
      .where(accumulated: false)
      .group("branches.name")
      .select("branches.name AS name", "COUNT(requests.id) AS count", "SUM(requests.amount_received) AS total")
  end

  def total_cash(monthly_reports)
    monthly_reports.joins(prescriber: {current_accounts: :bank})
      .map { |mr| divide_into_notes(mr.available_value.to_f) }
      .each_with_object(Hash.new(0)) { |hash, sums|
      hash.each { |key, value| sums[key] += value }
    }
  end

  def set_monthly_reports(closing_id)
    grouped = monthly_reports.where(closing_id: closing_id)
      .where(closing_id: closing_id)
      .group_by { |report| [report.envelope_number, report.situation] }

    grouped.map do |info, reports|
      {
        envelope_number: info[0].to_s.rjust(5, "0"),
        situation: info[1],
        monthly_reports: reports,
        quantity: reports.sum { |m| m.requests.size },
        available_value: reports.sum(&:available_value)
      }
    end
  end

  # def set_situation(monthly_reports)
  #   monthly_reports.map { |info| info[:info][1] }.last
  # end

  # def set_envelope_number(monthly_reports)
  #   monthly_reports.map { |info| info[:info][0] }.last.to_s.rjust(5, "0")
  # end
end
