class Bank < ApplicationRecord
  audited

  include PgSearch::Model

  validates :name, presence: {message: " deve estar preenchido!"}, uniqueness: {message: " já está cadastrado!"}
end
