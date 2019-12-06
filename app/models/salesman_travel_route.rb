class SalesmanTravelRoute < ApplicationRecord
  acts_as_paranoid

  belongs_to :salesman_travel
  belongs_to :location
  belongs_to :product_sale

  scope :by_queue, ->(travel_id, queue) {
    where(salesman_travel_id: travel_id)
        .where(queue: queue)
  }

  def loc_name
    location.name
  end

  def phone
    product_sale.phone
  end

  def latitude
    location.latitude
  end

  def longitude
    location.longitude
  end

  def product_count
    product_sale.count_product
  end
end
