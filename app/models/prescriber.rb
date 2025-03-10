class Prescriber < ApplicationRecord
  audited

  include PgSearch::Model
end
