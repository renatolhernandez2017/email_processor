class Representative < ApplicationRecord
  audited

  include PgSearch::Model
  include Roundable

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

  def self.monthly_reports_select(closing_id, representatives)
    representatives.group_by { |r| r.name }
      .map { |name, representative|
      load_reports = representative[0].load_monthly_reports(closing_id, [{prescriber: {current_accounts: :bank}}])

      if load_reports.present?
        {
          name: representative[0].name,
          monthly_reports: load_reports
        }
      end
    }.compact
  end

  def totals_by_bank(closing_id)
    monthly_reports_with_accounts(closing_id)
      .group_by { |m| m.prescriber&.current_accounts&.find_by(standard: true)&.bank&.name }
      .reject { |bank, _| bank.nil? }
      .map do |bank, reports|
        {
          count: reports.size,
          name: bank,
          total: reports.sum { |r| r.partnership - r.discounts }
        }
      end
  end

  def self.totals_by_bank_select(closing_id, representatives)
    representatives.flat_map { |representative|
      representative.totals_by_bank(closing_id)
    }.group_by { |bank| bank[:name] }
      .map { |name, banks|
      {
        name: name,
        count: banks.sum { |bank| bank[:count] },
        total: banks.sum { |bank| bank[:total] }
      }
    }
  end

  def totals_by_store(closing_id)
    monthly_reports_false(closing_id, [:requests, {representative: [:branch, :prescriber]}])
      .group_by { |m| m.prescriber&.representative&.branch&.name }
      .map do |branch, reports|
        {
          name: branch,
          count: reports.sum { |r| r.requests.count },
          total: reports.sum { |r| r.requests.sum(&:amount_received) }
        }
      end
  end

  def self.totals_by_store_select(closing_id, representatives)
    representatives.flat_map { |representative|
      representative.totals_by_store(closing_id)
    }.group_by { |bank| bank[:name] }
      .map { |name, banks|
      {
        name: name,
        count: banks.sum { |bank| bank[:count] },
        total: banks.sum { |bank| bank[:total] }
      }
    }
  end

  def total_cash(closing_id)
    monthly_reports_with_accounts(closing_id)
      .where.not(monthly_reports: {prescribers: {current_accounts: {id: nil}}})
      .map { |mr| divide_into_notes(mr.available_value.to_f) }
      .each_with_object(Hash.new(0)) { |hash, sums|
      hash.each { |key, value| sums[key] += value }
    }
  end

  def self.total_cash_select(closing_id, representatives)
    representatives.flat_map { |representative|
      representative.total_cash(closing_id)
    }.each_with_object({}) do |cash, acc|
      cash.each do |key, value|
        acc[key] = acc.fetch(key, 0) + value
      end
    end
  end

  private

  def scoped_monthly_reports(closing_id, eager_load)
    monthly_reports.includes(*eager_load)
      .where(closing_id: closing_id)
      .order("prescribers.name ASC")
  end

  def monthly_reports_with_accounts(closing_id)
    monthly_reports_false(closing_id, [{prescriber: {current_accounts: :bank}}])
  end
end
