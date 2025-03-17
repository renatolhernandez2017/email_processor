class Discount < ApplicationRecord
  belongs_to :prescriber, optional: true
  belongs_to :branch, optional: true
end
