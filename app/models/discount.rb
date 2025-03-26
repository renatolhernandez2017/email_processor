class Discount < ApplicationRecord
  audited

  include PgSearch::Model

  belongs_to :prescriber
  belongs_to :branch
  belongs_to :monthly_report, optional: true

  validates :price, presence: {message: " deve ser preenchido!"}
  validates :price, numericality: {greater_than: 0, less_than_or_equal_to: 99999.9, message: " deve ser um valor maior do que zero"}
  validates :prescriber_id, :branch_id, presence: {message: " deve ser selecionado"}

  validate :price_within_available_value

  private

  def price_within_available_value
    if monthly_report.present? && price > monthly_report&.available_value
      errors.add(:price, "valor máximo de #{monthly_report.available_value} foi excedido")
    end
  end
end
