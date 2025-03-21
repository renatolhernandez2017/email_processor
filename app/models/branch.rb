class Branch < ApplicationRecord
  audited

  include PgSearch::Model

  has_many :current_accounts, dependent: :destroy
end
