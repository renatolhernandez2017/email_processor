class Branch < ApplicationRecord
  audited

  include PgSearch::Model

  has_many :current_accounts, dependent: :destroy
  has_many :representatives, dependent: :destroy
  has_many :requests, dependent: :destroy
end
