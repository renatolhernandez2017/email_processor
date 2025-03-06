class Person < ApplicationRecord
  audited

  include PgSearch::Model
end
