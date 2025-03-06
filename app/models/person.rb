class Person < ApplicationRecord
  audited

  include PgSearch::Model

  has_many :addresses, dependent: :destroy
end
