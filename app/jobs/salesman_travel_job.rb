class SalesmanTravelJob < ApplicationJob
  queue_as :default

  def perform(obj_type, obj)
    ActionCable.server.broadcast 'salesman_travel_channel', parse_data(obj_type, obj)
  end

  private

  def parse_data(obj_type, obj)
    if obj_type == "sale"
      location = obj.location
      {obj_type: obj_type, latitude: location.latitude.to_s, longitude: location.longitude.to_s, sale_id: obj.id, phone: obj.phone, name: location.full_name, delivery_hour: obj.delivery_hour, allocation_type: obj.allocation_type}
    else
      {obj_type: obj_type, created_at: obj.created_at.strftime('%F %R'), salesman_id: obj.salesman_id, salesman_name: obj.salesman.name}
    end
  end
end
