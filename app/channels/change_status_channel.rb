class ChangeStatusChannel < ApplicationCable::Channel
  def subscribed
    stream_for "ChangeStatusChannel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
