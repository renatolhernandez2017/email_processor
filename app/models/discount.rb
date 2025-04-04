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

  after_save :update_monthly_report
  after_destroy :update_monthly_report

  private

  def price_within_available_value
    if monthly_report.present? && price > monthly_report&.available_value
      errors.add(:price, "valor máximo de #{monthly_report.available_value} foi excedido")
    end
  end

  def update_monthly_report
    if monthly_report
      discounts = Discount.where(monthly_report_id: monthly_report.id).sum(&:price)
      monthly_report.update(discounts: discounts || 0.0)
    end
  end
end
