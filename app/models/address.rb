class Address < ApplicationRecord
  audited

  include PgSearch::Model

  # belongs_to :representative, optional: true
end
