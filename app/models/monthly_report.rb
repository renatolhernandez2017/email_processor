class MonthlyReport < ApplicationRecord
  audited

  include PgSearch::Model
  include Roundable

  belongs_to :closing
  belongs_to :representative, optional: true
  belongs_to :prescriber

  has_many :requests, dependent: :destroy

  validates :closing_id, :prescriber_id, presence: {message: " devem ser preenchidos!"}

  def available_value
    return 0.00 if partnership <= 0.0

    if prescriber.current_accounts.find_by(standard: true)
      [partnership - discounts, 0].max
    else
      [round_to_ten((partnership - discounts).to_f), 0].max
    end
  end

  # def situation
  #   if accumulated
  #     "A"
  #   elsif !accumulated && prescriber&.current_accounts&.find_by(standard: true)
  #     "D"
  #   else
  #     "E"
  #   end
  # end
end
