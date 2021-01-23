class SalesmanTrackChannel < ApplicationCable::Channel
  def subscribed
    stream_from "salesman_track_channel"
  end

  def unsubscribed
  end
end
