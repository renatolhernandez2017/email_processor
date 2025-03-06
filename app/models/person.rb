class Person < ApplicationRecord
  audited

  include PgSearch::Model

  belongs_to :address, optional: true
end
