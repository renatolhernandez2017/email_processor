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
    joins(:representative, prescriber: {current_accounts: :bank}, requests: :branch)
      .select(<<~SQL.squish)
        monthly_reports.representative_id,
        representatives.name AS representative_name,
        branches.name AS branch_name,
        SUM(representatives.partnership) AS commission,
        SUM(requests.amount_received) AS total_requests,
        GREATEST((SUM(requests.amount_received) / NULLIF(monthly_reports.total_price, 0)) * (monthly_reports.partnership - monthly_reports.discounts), 0) AS branch_partnership,
        GREATEST((SUM(requests.amount_received) * SUM(representatives.partnership) / 100.0), 0) AS commission_payments_transfers,
        COUNT(requests.id) AS number_of_requests
      SQL
      .where(closing_id: closing_id, accumulated: false)
      .group("monthly_reports.id, representatives.name, branches.name")
      .group_by(&:branch_name)
  }

  scope :with_monthly_reports, lambda {
    select(<<~SQL)
      monthly_reports.id,
      monthly_reports.prescriber_id,
      monthly_reports.accumulated,
      monthly_reports.quantity,
      LPAD(CAST(monthly_reports.envelope_number AS TEXT), 6, '0') AS number_envelope,
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
          END,
        0)
      END AS with_available_value,
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
      .joins(:prescriber)
      .where(accumulated: false)
      .group(<<~SQL)
        monthly_reports.id,
        monthly_reports.accumulated,
        monthly_reports.quantity,
        monthly_reports.prescriber_id,
        prescribers.name,
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
            END,
          0)
        END,
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
      .order("prescribers.name")
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
