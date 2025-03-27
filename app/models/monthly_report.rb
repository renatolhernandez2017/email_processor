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
    # Pronto mais precisa ainda verificar melhor

    if prescriber.current_accounts.find_by(standard: true)
      if partnership
        partnership - self.discounts
      else
        0.00
      end
    elsif partnership
      (partnership - discounts).to_f.round_to_ten
    else
      0.00
    end
  end

  def situation
    # Pronto mais precisa ainda verificar melhor
    if accumulated
      "A"
    elsif !accumulated && !current_account.nil?
      "D"
    else
      "E"
    end
  end
end
