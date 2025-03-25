class MonthlyReport < ApplicationRecord
  audited

  include PgSearch::Model

  belongs_to :closing, optional: true
  belongs_to :representative, optional: true
  belongs_to :prescriber, optional: true
end
