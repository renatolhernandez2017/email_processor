class MonthlyReport < ApplicationRecord
  audited

  include PgSearch::Model

  belongs_to :closing, optional: true
end
