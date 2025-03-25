class Discount < ApplicationRecord
  audited

  include PgSearch::Model

  belongs_to :prescriber
  belongs_to :branch

  validates :price, presence: {message: " deve ser preenchido!"}
  validates :price, numericality: {greater_than: 0, less_than_or_equal_to: 99999.9, message: " deve ser um valor maior do que zero"}
  validates :prescriber_id, :branch_id, presence: {message: " deve ser selecionado"}
end
