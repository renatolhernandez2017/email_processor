class EmailFile < ApplicationRecord
  has_many :processing_logs, dependent: :destroy

  validates :filename, :path, presence: true
end
