class EmailChannel < ApplicationCable::Channel
  def subscribed
    stream_for "emails"
  end
end
