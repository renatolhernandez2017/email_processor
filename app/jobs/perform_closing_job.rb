class PerformClosingJob
  include Sidekiq::Job

  sidekiq_options queue: :closings, lock: :until_executed, lock_args_method: ->(args) { args }

  def perform(closing_id)
    closing = Closing.find(closing_id)
    ClosingProcessor.new(closing).call
  end
end
