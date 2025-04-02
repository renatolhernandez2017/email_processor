class Request < ApplicationRecord
  audited

  include PgSearch::Model

  belongs_to :branch, optional: true
  belongs_to :monthly_report, optional: true
  belongs_to :prescriber, optional: true
  belongs_to :representative, optional: true

  has_one :discount, dependent: :destroy
end
