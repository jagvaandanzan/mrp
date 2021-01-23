class SalesmanTrackJob < ApplicationJob
  queue_as :default

  def perform(salesman_track_id)
    ActionCable.server.broadcast 'salesman_track_channel', salesman_track_id: salesman_track_id
  end

end
