class Branch < ApplicationRecord
  audited

  include PgSearch::Model

  has_many :current_accounts, dependent: :destroy
  has_many :representatives, dependent: :destroy
  has_many :requests, dependent: :destroy

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
end
