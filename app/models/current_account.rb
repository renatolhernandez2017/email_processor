class CurrentAccount < ApplicationRecord
  belongs_to :bank_information, optional: true
  belongs_to :representative, optional: true
end
