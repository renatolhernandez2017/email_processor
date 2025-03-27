class Bank < ApplicationRecord
  audited

  include PgSearch::Model

  validates :name, presence: {message: " deve estar preenchido!"}
end
