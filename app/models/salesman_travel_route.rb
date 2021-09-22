class SalesmanTravelRoute < ApplicationRecord
  # acts_as_paranoid

  belongs_to :salesman_travel
  belongs_to :location
  belongs_to :product_sale

  has_one :status, through: :product_sale

  attr_accessor :is_update, :feature_item_ids

  validates_uniqueness_of :product_sale_id, scope: [:salesman_travel_id]
  validates :queue, presence: true

  scope :order_queue, ->() {
    order(:queue)
  }
  scope :by_travel_id, ->(travel_id) {
    where(salesman_travel_id: travel_id)
  }

  scope :by_queue, ->(queue) {
    where(queue: queue)
  }

  scope :not_ni_wage, ->() {
    where("salesman_travel_routes.wage IS NOT ?", nil)
  }

  scope :search, ->(start, finish, salesman_id) {
    joins(:salesman_travel)
        .where('salesman_travels.delivery_at >= :s AND salesman_travels.delivery_at < :f', s: "#{start}", f: "#{finish + 1.day}")
        .where('salesman_travels.salesman_id = ?', salesman_id)
        .order("salesman_travel_routes.delivery_at")
  }

  scope :after_queue, ->(queue) {
    where("queue >= ?", queue)
  }

  scope :nil_delivered_at, ->() {
    where("delivered_at IS ?", nil)
  }

  scope :by_salesman_id, ->(salesman_id) {
    joins(:salesman_travel)
        .where('salesman_travels.salesman_id = ?', salesman_id)
  }

  scope :by_day, ->(start_time, end_time) {
    where('salesman_travel_routes.delivered_at IS NOT ?', nil)
        .where('salesman_travel_routes.delivered_at >= ?', start_time)
        .where('salesman_travel_routes.delivered_at < ?', end_time + 1.days)
  }
  scope :by_wage_nil, ->(is_nil) {
    where("salesman_travel_routes.wage IS#{is_nil ? '' : ' NOT'} ?", nil)
  }

  scope :by_status, ->(status) {
    left_joins(:status)
        .where('product_sale_statuses.alias = ?', status)
  }
  scope :by_status_ids, ->(status_ids) {
    left_joins(:product_sale)
        .where('product_sales.status_id IN (?)', status_ids)
  }
  scope :by_not_status, ->(status_ids) {
    left_joins(:product_sale)
        .where('product_sales.status_id NOT IN (?)', status_ids)
  }
  scope :contain_exchange, ->(cont) {
    where("product_sales.parent_id IS#{cont ? ' NOT' : ''} ?", nil)
  }
  scope :can_delivery_time, ->() {
    where("salesman_travel_routes.delivered_at >= salesman_travel_routes.delivered_at")
  }

  scope :by_daily, ->(salesman_id) {
    select("DATE_FORMAT(salesman_travel_routes.delivered_at,'%Y-%m-%d') as day,
                        SUM(salesman_travel_routes.wage) as wage,
                        SUM(salesman_travel_routes.distribution) as distribution,
                        SUM(product_sale_statuses.alias = 'sals_delivered') as delivered")
        .joins(:salesman_travel)
        .left_joins(:status)
        .where('salesman_travels.salesman_id = ?', salesman_id)
        .group("day")
  }

  def loc_name
    # if location.station.present?
    #   location.station.name_reverse
    # else
    location.name_reverse
    # end
  end

  def loc_note
    product_sale.loc_note
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

  def has_any_bought
    product_sale
        .product_sale_items
        .sum(:bought_quantity)
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
    c = product_sale.count_product
    c.presence || 0
  end

  def return_count
    product_sale.product_sale_returns.count
  end

  def status
    product_sale.status_name
  end

  def delivery_hour
    product_sale.delivery_hour
  end

  def calculate_payable
    s = 0
    has_items = product_sale.product_sale_items.present?
    if product_sale.present? && has_items
      product_sale.product_sale_items.each do |item|
        s += (item.price * item.bought_quantity) if item.price.present? && item.bought_quantity.present? && item.bought_quantity > 0
      end
    end

    self.payable = if s >= 0 && has_items
                     s - (product_sale.paid.presence || 0) + (s < Const::FREE_SHIPPING ? Const::SHIPPING_FEE : 0)
                   else
                     nil
                   end
    self.save
  end

  def calculate_delivery
    self.update_columns(delivered_at: Time.now, delivery_time: ApplicationController.helpers.get_minutes(Time.now, delivery_at))
  end

  def calculate_wage
    # Үнэлгээ тооцох
    salesman = salesman_travel.salesman
    d = 1
    if product_sale.parent_id.present?
      self.update_column(:wage, wage.present? ? wage + Const::DISTRIBUTION[0] : Const::DISTRIBUTION[0])
    else

      d = product_sale.distribution
      if location.country.present? && location.country
        d /= 3
      end
      w = if location.distance_d?
            if d >= 3
              d * salesman.price
            else
              d * Const::DISTRIBUTION[4 + d]
            end
          else
            d * salesman.price
          end
      self.update_columns(wage: w.to_i, distribution: d)
    end

    distributions = (salesman.distribution.present? ? salesman.distribution : 0) + d
    if distributions >= Const::DISTRIBUTION[7]
      if (Time.current - salesman.price_at).to_i >= 180
        salesman.update_columns(distribution: 0, price_at: Time.current, price: salesman.price == Const::DISTRIBUTION[2] ? Const::DISTRIBUTION[3] : Const::DISTRIBUTION[4])
      else
        salesman.update_column(:distribution, distributions)
      end
    else
      salesman.update_column(:distribution, distributions)
    end
  end

end