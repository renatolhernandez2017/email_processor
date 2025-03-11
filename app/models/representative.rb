class Representative < ApplicationRecord
  audited

  include PgSearch::Model

  belongs_to :branch, optional: true

  has_one :address, dependent: :destroy
end
