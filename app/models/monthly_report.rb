class MonthlyReport < ApplicationRecord
  audited

  include PgSearch::Model
  include Roundable

  belongs_to :closing
  belongs_to :representative, optional: true
  belongs_to :prescriber

  # has_many :discounts, dependent: :destroy

  validates :closing_id, :prescriber_id, presence: {message: " devem ser preenchidos!"}

  def available_value
    return 0.00 unless partnership

    if prescriber.current_accounts.find_by(standard: true)
      partnership - discounts
    else
      round_to_ten((partnership - discounts).to_f)
    end
  end

  def situation
    # Pronto mais precisa ainda verificar melhor
    if accumulated
      "A"
    elsif !accumulated && current_account
      "D"
    else
      "E"
    end
  end
end
