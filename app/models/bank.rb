class Bank < ApplicationRecord
  audited

  include PgSearch::Model

  validates :name, presence: {message: " deve estar preenchido!"}

  has_many :current_accounts, dependent: :destroy
end
