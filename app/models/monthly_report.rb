class MonthlyReport < ApplicationRecord
  audited

  include PgSearch::Model

  belongs_to :closing, optional: true
  belongs_to :representative, optional: true
  belongs_to :prescriber, optional: true

  has_many :discounts, dependent: :destroy

  validates :closing_id, :prescriber_id, presence: {message: " devem ser preenchidos!"}
end
