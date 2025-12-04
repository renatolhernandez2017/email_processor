class EmailChannel < ApplicationCable::Channel
  def subscribed
    stream_for "email"
  end
end
