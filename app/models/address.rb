class Address < ApplicationRecord
  audited

  include PgSearch::Model

  belongs_to :person, optional: true
end
