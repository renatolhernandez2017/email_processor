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
    Sidekiq::Workers.new.any? do |_, _, work_str|
      work = work_str.is_a?(String) ? JSON.parse(work_str) : work_str

      args = work.dig("payload", "args")
      klass = work.dig("payload", "class")
      klass == self.class.name && args == [closing_id]
    rescue
      false
    end
  end
end
