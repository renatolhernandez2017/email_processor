class Representative < ApplicationRecord
  audited

  include PgSearch::Model
  include Representative::Aggregations

  belongs_to :branch, optional: true

  has_one :address, dependent: :destroy

  has_many :prescribers, dependent: :destroy
  has_many :current_accounts, dependent: :destroy
  has_many :monthly_reports, dependent: :destroy
  has_many :requests, dependent: :destroy

  pg_search_scope :search_global,
    against: [:id, :name, :number],
    using: {
      tsearch: {
        prefix: true,
        any_word: true, # Busca qualquer palavra do nome de estiver como true
        dictionary: "portuguese"
      }
    },
    order_within_rank: "name",
    ignoring: :accents
end
