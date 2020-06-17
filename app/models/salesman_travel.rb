class SalesmanTravel < ApplicationRecord
  belongs_to :salesman
  belongs_to :user, optional: true

  has_many :salesman_travel_routes, -> {with_deleted.order(:queue)}
  has_many :product_sales
  has_one :salesman_travel_sign, dependent: :destroy
  has_many :product_warehouse_locs, -> {order(:queue)}, dependent: :destroy

  scope :open_delivery, ->(salesman_id) {
    where(salesman_id: salesman_id)
        .where("delivered_at IS ?", nil)
        .order(:created_at)
  }

  scope :travels, ->(salesman_id, date) {
    where(salesman_id: salesman_id)
        .where('delivery_at >= ?', date)
        .where('delivery_at < ?', date + 1.days)
        .order(:delivery_at)
        .order(created_at: :desc)
  }

  scope :by_id_and_salesman, ->(id, salesman_id) {
    where(salesman_id: salesman_id)
        .where(id: id)
  }

  scope :by_load_at, ->(loaded, date) {
    if loaded
      items = where("load_at IS#{loaded ? " NOT" : ""} ?", nil)
      items = items.where('load_at >= ?', date)
                  .where('load_at < ?', date + 1.days) if date.present?
      items
    else
      where("load_at IS ?", nil)
    end
  }

  def id_number
    id.to_s.rjust(5, '0')
  end

  def route_count
    salesman_travel_routes.count
  end

  def load_count
    product_warehouse_locs.by_load_at(true).count
  end

  def load_sum
    product_warehouse_locs.count
  end

  def product_count
    total = 0
    salesman_travel_routes.each do |r|
      total += r.product_count
    end
    total
  end

  def on_sign
    now = Time.now
    if salesman_travel_routes.present?
      self.update_columns(load_at: now, delivery_at: now + (duration * 60))

      salesman_travel_routes.each do |route|
        to_time = now + (route.duration * 60)
        route.update_columns(load_at: now, delivery_at: to_time)
        now = to_time
      end
    end
  end

  def calculate_delivery
    c = 0
    if salesman_travel_routes.present?
      salesman_travel_routes.each do |route|
        if route.delivered_at.present?
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
