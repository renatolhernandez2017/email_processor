class Bank < ApplicationRecord
  audited

  include PgSearch::Model
end
