class EmailProcessorJob
  include Sidekiq::Job

  sidekiq_options queue: :email, lock: :until_executed, lock_args_method: ->(args) { args }

  def perform(email_id)
    email_file = EmailFile.find(email_id)

    ProcessorEmail.new(email_file).process!
  end
end
