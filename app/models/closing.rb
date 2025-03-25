class Closing < ApplicationRecord
  audited

  include PgSearch::Model

  has_many :monthly_reports, dependent: :destroy

  validates :start_date, presence: {message: " deve estar preenchido!"}
  validates :closing, presence: {message: " deve estar preenchido!"}, uniqueness: {message: " já está cadastrado!"}
end
