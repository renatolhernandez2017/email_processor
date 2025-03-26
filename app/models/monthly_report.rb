class MonthlyReport < ApplicationRecord
  audited

  include PgSearch::Model

  belongs_to :closing, optional: true
  belongs_to :representative, optional: true
  belongs_to :prescriber, optional: true

  validates :closing_id, :prescriber_id, presence: {message: " deve ser preenchido!"}
end
