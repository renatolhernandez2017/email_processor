class User < ApplicationRecord
  include StatusDetailManageable
  include Countable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable

  validates :name, presence: true
  validates :email, format: {with: URI::MailTo::EMAIL_REGEXP}
end
