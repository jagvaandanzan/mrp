class SalesmanTravelChannel < ApplicationCable::Channel
  def subscribed
    stream_from "salesman_travel_channel"
  end

  def unsubscribed
  end
end
