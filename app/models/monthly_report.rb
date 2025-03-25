class MonthlyReport < ApplicationRecord
  audited

  include PgSearch::Model
end
