class Representative < ApplicationRecord
  audited

  include PgSearch::Model

  belongs_to :branch, optional: true

  has_one :address, dependent: :destroy
  has_one :prescriber, dependent: :destroy

  has_many :current_accounts, dependent: :destroy
  has_many :monthly_reports, dependent: :destroy
  has_many :requests, dependent: :destroy
end
