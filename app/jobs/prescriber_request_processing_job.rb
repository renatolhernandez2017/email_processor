class PrescriberRequestProcessingJob < ApplicationJob
  queue_as :default

  def perform
    prescribers = Prescriber
      .includes(:representative, :address)
      .select(:id, :name, :created_at, :representative_id, :class_council, :uf_council, :number_council)
      .order(created_at: :desc)

    # 1. Processa ensure_address
    prescribers.find_each do |prescriber|
      prescriber.ensure_address
    end
  end
end
