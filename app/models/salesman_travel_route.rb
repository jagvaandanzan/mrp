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

  def payable
    if self[:payable].present?
      self[:payable]
    else
      product_sale.sum_price
    end
  end

  def main_payable
    self[:payable]
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

  def calculate_payable
    s = 0
    if product_sale.present? && product_sale.product_sale_items.present?
      product_sale.product_sale_items.each do |item|
        s += (item.price * item.bought_quantity) if item.price.present? && item.bought_quantity.present?
      end
    end

    self.payable = if s > 0
                     s - (product_sale.paid.presence || 0)
                   else
                     nil
                   end
    self.save
  end

  def calculate_delivery
      self.delivered_at = Time.now
      self.delivery_time = ApplicationController.helpers.get_minutes(delivered_at, load_at)
    self.save
  end
end
