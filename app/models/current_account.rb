class CurrentAccount < ApplicationRecord
  audited

  include PgSearch::Model

  belongs_to :bank, optional: true
  belongs_to :branch, optional: true
  belongs_to :representative, optional: true
  belongs_to :prescriber, optional: true

  accepts_nested_attributes_for :bank

  validates :favored, presence: {message: "deve ser preenchido"}

  def update_others_standard(route, current_account)
    return unless route == "prescriber" || route == "representative" || route == "branch"

    object = case route
    when "prescriber"
      {prescriber_id: current_account.prescriber_id}
    when "representative"
      {representative_id: current_account.representative_id}
    when "branch"
      {branch_id: current_account.branch_id}
    end

    current_accounts = CurrentAccount.where(object)
    current_accounts.update_all(standard: false)
  end
end
