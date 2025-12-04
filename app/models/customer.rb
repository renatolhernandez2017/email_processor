class Customer < ApplicationRecord
  audited

  validates :name, presence: true
  validates :email, presence: true
  validates :phone, presence: true
end
