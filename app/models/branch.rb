class Branch < ApplicationRecord
  audited

  include PgSearch::Model
end
