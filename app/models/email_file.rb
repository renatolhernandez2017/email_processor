class EmailFile < ApplicationRecord
  audited

  has_many :processing_logs, dependent: :destroy

  validates :filename, :path, presence: true
end
