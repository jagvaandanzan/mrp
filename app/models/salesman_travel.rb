class SalesmanTravel < ApplicationRecord
  belongs_to :salesman
  belongs_to :user, optional: true

  has_many :salesman_travel_routes, -> {with_deleted.order(:queue)}
  has_many :product_sales

  scope :open_delivery, ->(salesman_id) {
    where(salesman_id: salesman_id)
        .where("delivered_at IS ?", nil)
        .order(:created_at)
  }

  scope :travels, ->(salesman_id, date) {
    where(salesman_id: salesman_id)
        .where('delivery_at >= ?', date)
        .where('delivery_at < ?', date + 1.days)
        .order(:delivered_at)
        .order(created_at: :desc)
  }

  scope :by_id_and_salesman, ->(id, salesman_id) {
    where(salesman_id: salesman_id)
        .where(id: id)
  }

  def route_count
    salesman_travel_routes.count
  end

  def product_count
    total = 0
    salesman_travel_routes.each do |r|
      total += r.product_count
    end
    total
  end

  def calculate_delivery
    c = 0
    if salesman_travel_routes.present?
      salesman_travel_routes.each do |route|
        if route.main_payable.present?
          c += 1
        end
      end

      if salesman_travel_routes.length == c
        self.delivered_at = Time.now
        self.delivery_time = ApplicationController.helpers.get_minutes(delivered_at, load_at)
      else
        self.delivered_at = nil
        self.delivery_time = nil
      end
      self.save
    end
  end
end
