class ProcessingLog < ApplicationRecord
  audited

  belongs_to :email_file
end
