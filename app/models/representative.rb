class Representative < ApplicationRecord
  audited

  include PgSearch::Model

  belongs_to :prescriber, optional: true
  belongs_to :branch, optional: true

  has_one :address, dependent: :destroy
  has_one :current_account, dependent: :destroy

  accepts_nested_attributes_for :address
end
