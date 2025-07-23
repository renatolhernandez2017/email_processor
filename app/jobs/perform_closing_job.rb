class PerformClosingJob < ApplicationJob
  queue_as :closings

  def perform(closing_id)
    if job_already_running?(closing_id)
      Rails.logger.warn("Já existe um fechamento em andamento para Closing ##{closing_id}")
      return
    end

    closing = Closing.find(closing_id)
    ClosingProcessor.new(closing).call
  end

  private

  def job_already_running?(closing_id)
    Sidekiq::Workers.new.any? do |_, _, work|
      job = work["payload"]
      next false unless job

      job_class = job["class"]
      job_args = job["args"]

      job_class == self.class.name && job_args == [closing_id]
    end
  rescue => e
    Rails.logger.error("Erro ao verificar jobs em andamento: #{e.message}")
    false
  end
end
