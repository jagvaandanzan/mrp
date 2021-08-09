class SalesmanRequest < ApplicationRecord
  belongs_to :salesman
  belongs_to :salesman_travel, optional: true

  after_create :send_to_channel

  scope :by_travel_nil, ->(id = nil) {
    items = if id.nil?
              where("salesman_travel_id IS ?", nil)
            else
              where("salesman_travel_id IS ? OR salesman_id = ?", nil, id)
            end
    items.order(:created_at)
  }
  scope :by_salesman_id, ->(salesman_id) {
    where(salesman_id: salesman_id)
  }

  def salesman_name
    salesman.name
  end

  private

  def send_to_channel
    SalesmanTravelJob.perform_later("request", self)
  end
end
