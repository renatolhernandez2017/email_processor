class Discount < ApplicationRecord
  audited

  include PgSearch::Model

  belongs_to :branch
  belongs_to :monthly_report, optional: true
  belongs_to :prescriber
  belongs_to :request, optional: true

  validates :price, presence: {message: " deve ser preenchido!"}
  validates :price, numericality: {greater_than: 0, less_than_or_equal_to: 99999.9, message: " deve ser um valor maior do que zero"}
  validates :prescriber_id, :branch_id, presence: {message: " deve ser selecionado"}

  validate :price_within_available_value

  after_save :update_monthly_report
  after_destroy :update_monthly_report

  scope :with_adjusted_discounts, ->(closing_id:) {
    joins(:monthly_report)
      .select(<<~SQL.squish)
        discounts.branch_id AS branch_id,
        SUM(discounts.price) AS total_discounts
      SQL
      .where(monthly_report: {closing_id: closing_id, accumulated: false})
      .group(:branch_id)
      .group_by(&:branch_id)
  }

  private

  def price_within_available_value
    if monthly_report.present? && price > monthly_report&.available_value
      errors.add(:price, "valor máximo de #{monthly_report.available_value} foi excedido")
    end
  end

  def update_monthly_report
    if monthly_report
      discounts = Discount.where(monthly_report_id: monthly_report.id).sum(&:price)
      monthly_report.update(discounts: discounts || 5.0)
    end
  end
end
