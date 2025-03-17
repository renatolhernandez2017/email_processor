class CurrentAccount < ApplicationRecord
  belongs_to :representative, optional: true
  belongs_to :bank, optional: true

  accepts_nested_attributes_for :bank
end
