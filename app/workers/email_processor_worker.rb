class EmailProcessorWorker
  include Sidekiq::Worker

  def broadcast_step(email_id, message)
    ActionCable.server.broadcast(
      "email_files",
      { step: message }
    )
  end

  def perform(email_id)
    broadcast_step(email_id, "Arquivo recebido")

    email_file = EmailFile.find(email_id)

    sleep 1
    broadcast_step(email_id, "Lendo arquivo")

    EmailProcessor.new(email_file).process!
  end
end
