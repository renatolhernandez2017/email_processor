class ProcessingLog < ApplicationRecord
  belongs_to :email_file

  serialize :data, JSON
end
