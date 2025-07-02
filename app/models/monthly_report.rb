class MonthlyReport < ApplicationRecord
  audited

  include PgSearch::Model
  include Roundable

  belongs_to :closing
  belongs_to :representative, optional: true
  belongs_to :prescriber

  has_many :requests, dependent: :destroy

  validates :closing_id, :prescriber_id, presence: {message: " devem ser preenchidos!"}

  scope :with_adjusted_billings, ->(closing_id:) {
    joins(:requests, :representative)
      .select(<<~SQL.squish)
        monthly_reports.representative_id,
        representatives.name AS representative_name,
        requests.branch_id AS branch_id,
        SUM(representatives.partnership) AS commission,
        SUM(requests.amount_received) AS total_requests,
        GREATEST((SUM(requests.amount_received) / monthly_reports.total_price) * (monthly_reports.partnership - monthly_reports.discounts), 0) AS branch_partnership,
        GREATEST((SUM(requests.amount_received) * SUM(representatives.partnership) / 100.0), 0) AS commission_payments_transfers,
        COUNT(requests.id) AS number_of_requests
      SQL
      .where(closing_id: closing_id, accumulated: false)
      .group("monthly_reports.representative_id, representatives.name, requests.branch_id, monthly_reports.partnership, monthly_reports.discounts, monthly_reports.total_price")
      .group_by { |m| m.branch_id }
  }

  def available_value
    return 0.00 if partnership <= 0.0

    if prescriber.current_accounts.find_by(standard: true)
      [partnership - discounts, 0].max
    else
      [round_to_ten((partnership - discounts).to_f), 0].max
    end
  end

  def situation
    if accumulated
      "A"
    elsif !accumulated && prescriber&.current_accounts&.find_by(standard: true)
      "D"
    else
      "E"
    end
  end
end
