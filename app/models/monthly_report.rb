class MonthlyReport < ApplicationRecord
  audited

  include PgSearch::Model
  include Roundable

  belongs_to :closing
  belongs_to :representative, optional: true
  belongs_to :prescriber

  has_many :requests, dependent: :destroy
  has_many :current_accounts, through: :prescriber

  validates :closing_id, :prescriber_id, presence: {message: " devem ser preenchidos!"}

  scope :with_adjusted_billings, ->(closing_id) {
    joins(:representative, prescriber: {current_accounts: :bank}, requests: :branch)
      .select(<<~SQL.squish)
        monthly_reports.representative_id,
        representatives.name AS representative_name,
        branches.name AS branch_name,
        SUM(monthly_reports.discounts) AS total_discounts,
        MAX(representatives.partnership) AS commission,
        SUM(DISTINCT requests.amount_received) AS total_requests,
        GREATEST(
          (SUM(DISTINCT requests.amount_received) / NULLIF(MAX(monthly_reports.total_price), 0)) * 
          (MAX(monthly_reports.partnership) - SUM(monthly_reports.discounts)), 0
        ) AS branch_partnership,
        GREATEST(
          SUM(DISTINCT requests.amount_received) * MAX(representatives.partnership) / 100.0, 0
        ) AS commission_payments_transfers,
        COUNT(DISTINCT requests.id) AS number_of_requests
      SQL
      .where(closing_id: closing_id, accumulated: false)
      .group("monthly_reports.representative_id, representatives.name, branches.name")
      .group_by(&:branch_name)
  }

  # def situation
  #   if accumulated
  #     "A"
  #   elsif !accumulated && !prescriber.current_accounts.nil?
  #     "D"
  #   else
  #     "E"
  #   end
  # end

  def available_value
    current_account = prescriber.current_accounts.find_by(standard: true)

    # quebrar

    if current_account.present?
      if partnership > 0.0
        [partnership - discounts, 0].max
      else
        0.0
      end
    else
      if partnership > 0.0
        [round_to_ten((partnership - discounts).to_f), 0].max
      else
        0.0
      end
    end

    # return 0.00 if partnership <= 0.0

    # if prescriber.current_accounts.find_by(standard: true)
    #   [partnership - discounts, 0].max
    # else
    #   [round_to_ten((partnership - discounts).to_f), 0].max
    # end
  end
end
