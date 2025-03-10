class Prescriber < ApplicationRecord
  audited

  include PgSearch::Model

  belongs_to :representative, optional: true
end
