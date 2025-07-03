class User < ApplicationRecord
  audited

  include PgSearch::Model

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable

  validates :name, presence: true
  validates :email, format: {with: URI::MailTo::EMAIL_REGEXP}

  pg_search_scope :search_global,
    against: [:name],
    using: {
      tsearch: {
        prefix: true,
        any_word: true, # Busca qualquer palavra do nome
        dictionary: "portuguese"
      }
    },
    order_within_rank: "name",
    ignoring: :accents

  def admin?
    role == "admin"
  end
end
