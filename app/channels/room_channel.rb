class RoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "room_channel"
    # stream_from "room_channel: #{curr_user.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
