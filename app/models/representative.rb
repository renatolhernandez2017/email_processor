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
    against: [:name, :number, :branch_id],
    using: {
      tsearch: {
        prefix: true,
        any_word: true, # Busca qualquer palavra do nome
        dictionary: "portuguese"
      }
    },
    order_within_rank: "name",
    ignoring: :accents

  scope :with_totals, ->(closing_id) {
    left_joins(:monthly_reports)
      .joins(<<~SQL.squish)
        LEFT JOIN current_accounts ca_standard
          ON ca_standard.prescriber_id = monthly_reports.prescriber_id
          AND ca_standard.standard = TRUE
      SQL
      .where(active: true, monthly_reports: {closing_id: closing_id})
      .group("representatives.id, representatives.name")
      .order("representatives.name ASC")
  }
end
