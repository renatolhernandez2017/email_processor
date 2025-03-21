class CurrentAccount < ApplicationRecord
  belongs_to :bank, optional: true
  belongs_to :branch, optional: true
  belongs_to :representative, optional: true
  belongs_to :prescriber, optional: true

  accepts_nested_attributes_for :bank

  before_create :unset_previous_standard
  after_create :set_as_standard

  private

  def unset_previous_standard
    CurrentAccount.where(standard: true).update_all(standard: false)
  end

  def set_as_standard
    update_column(:standard, true)
  end
end
