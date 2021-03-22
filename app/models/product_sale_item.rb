class ProductSaleItem < ApplicationRecord
  belongs_to :product_sale
  belongs_to :product
  belongs_to :feature_item, :class_name => "ProductFeatureItem"
  belongs_to :parent, :class_name => "ProductSaleItem", optional: true

  has_many :salesman_returns, :class_name => "SalesmanReturn", :foreign_key => "sale_item_id", dependent: :destroy
  has_one :product_balance, :class_name => "ProductBalance", :foreign_key => "sale_item_id", dependent: :destroy
  has_one :bonus_balance, dependent: :destroy
  has_one :salesman_travel, through: :product_sale
  has_one :status, through: :product_sale
  has_one :salesman_travel_route, through: :product_sale

  before_save :set_product_balance

  validates :product_id, :feature_item_id, :price, :quantity, presence: true
  validates :quantity, :price, numericality: {greater_than: 0}
  validates_numericality_of :quantity, less_than_or_equal_to: Proc.new(&:remainder)

  before_validation :set_remainder
  attr_accessor :remainder, :p_price, :p_6_8, :p_9_

  scope :find_by_salesman_id, ->(feature_item_id, salesman_id) {
    joins(:salesman_travel)
        .where("salesman_travels.salesman_id = ?", salesman_id)
        .where(feature_item_id: feature_item_id)
        .where("quantity - IFNULL(bought_quantity, 0) - IFNULL(back_quantity, 0) > ?", 0)
  }

  scope :sale_available, ->(salesman_id) {
    joins(:salesman_travel)
        .joins(:product)
        .where("salesman_travels.salesman_id = ?", salesman_id)
        .where("quantity - IFNULL(bought_quantity, 0) - IFNULL(back_quantity, 0) > ?", 0)
        .order("products.code")
        .order("products.n_name")
  }

  scope :status_not_confirmed, ->() {
    joins(:status)
        .where.not('product_sale_statuses.alias = ?', 'oper_confirmed')
  }

  scope :report_sale_delivered, ->(salesman_id, start_time, end_time) {
    left_joins(:salesman_travel_route)
        .left_joins(:salesman_travel)
        .where("salesman_travels.salesman_id = ?", salesman_id)
        .where('salesman_travel_routes.delivered_at IS NOT ?', nil)
        .where('salesman_travel_routes.delivered_at >= ?', start_time)
        .where('salesman_travel_routes.delivered_at < ?', end_time + 1.days)
        .where('product_sale_items.bought_quantity IS NOT ?', nil)
  }

  scope :count_item_quantity, ->(travel_id) {
    joins(:salesman_travel)
        .where("salesman_travels.id = ?", travel_id)
        .sum(:quantity)
  }

  scope :not_nil_bought_quantity, ->() {
    where("bought_quantity IS NOT ?", nil)
  }

  scope :not_buy_by_travel_ids, ->(travel_ids) {
    joins(:salesman_travel)
        .where("salesman_travels.id IN (?)", travel_ids)
        .where("bought_quantity IS ?", nil)
  }

  def price
    ApplicationController.helpers.get_f(self[:price])
  end

  def sum_price
    ApplicationController.helpers.get_f(self[:sum_price])
  end

  def product_image
    feature_item.img
  end

  def product_feature
    feature_item.name
  end

  def product_name
    product.name
  end

  def product_code
    product.code
  end

  def product_full_name
    product_name + ", " + product_feature
  end

  def phone
    product_sale.phone
  end

  def product_barcode
    feature_item.barcode
  end

  def back_request
    salesman_returns.count > 0
  end

  def add_bonus
    if bought_quantity.present?
      bonu = Bonu.by_phone(product_sale.phone)
      b_model = if bonu.present?
                  bonu.first
                else
                  b = Bonu.new(balance: 0)
                  b.bonus_phones << BonusPhone.new(phone: product_sale.phone)
                  b.save
                  b
                end
      if bonus_balance.present?
        self.bonus_balance.update(bonu: b_model, bonus: ApplicationController.helpers.get_percentage(bought_quantity * price, 5))
      else
        self.bonus_balance = BonusBalance.create(bonu: b_model, product_sale_item: self, bonus: ApplicationController.helpers.get_percentage(bought_quantity * price, 5))
      end
    end
  end

  private

  def set_product_balance
    if product_balance.present?
      self.product_balance.update(
          product: product,
          feature_item: feature_item,
          operator: product_sale.created_operator,
          quantity: -quantity)
    else
      self.product_balance = ProductBalance.create(product: product,
                                                   feature_item: feature_item,
                                                   operator: product_sale.created_operator,
                                                   quantity: -quantity)
    end
  end

  def set_remainder
    self.remainder = feature_item.balance + (quantity_was.presence || 0) if product_id.present? && feature_item_id.present?
  end

end
