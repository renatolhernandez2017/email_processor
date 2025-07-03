class ClosingChannel < ApplicationCable::Channel
  def subscribed
    stream_for "closing_#{params[:closing_id]}"
  end
end
