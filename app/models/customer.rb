class Customer < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true, unless: -> { phone.present? }
  validates :phone, presence: true, unless: -> { email.present? }
end
