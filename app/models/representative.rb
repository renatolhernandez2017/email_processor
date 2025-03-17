class Representative < ApplicationRecord
  audited

  include PgSearch::Model

  belongs_to :prescriber, optional: true
  belongs_to :branch, optional: true
  belongs_to :current_account, optional: true

  has_one :address, dependent: :destroy

  accepts_nested_attributes_for :address
  accepts_nested_attributes_for :current_account
end
