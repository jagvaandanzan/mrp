class ProductSaleItem < ApplicationRecord
  belongs_to :product_sale
  belongs_to :product
  belongs_to :feature_item, :class_name => "ProductFeatureItem"

  has_many :salesman_returns, :class_name => "SalesmanReturn", :foreign_key => "sale_item_id", dependent: :destroy
  has_one :product_balance, :class_name => "ProductBalance", :foreign_key => "sale_item_id", dependent: :destroy
  has_one :salesman_travel, through: :product_sale

  before_save :set_defaults
  before_save :set_product_balance

  before_create -> {create_exchange('create')}
  before_update -> {create_exchange('update')}
  before_destroy -> {create_exchange('delete')}

  validates :product_id, :feature_item_id, :price, :quantity, presence: true
  validates :quantity, :price, numericality: {greater_than: 0}
  validates_numericality_of :quantity, less_than_or_equal_to: Proc.new(&:remainder)

  before_validation :set_remainder
  attr_accessor :remainder

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
    joins(:product_sale)
        .where.not("product_sales.main_status_id = ?", 2)
  }

  scope :report_sale_delivered, ->(salesman_id, start_time, end_time) {
    left_joins(:product_sale)
        .left_joins(:salesman_travel)
        .where("salesman_travels.salesman_id = ?", salesman_id)
        .where("product_sale_items.created_at >= ?", start_time)
        .where("product_sale_items.created_at <= ?", end_time)
        .select("SUM(product_sale_items.sum_price) as price, SUM(bought_quantity) as bought, SUM(back_quantity) as back")
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

  def get_balance
    ProductBalance.balance(product_id, feature_item_id)
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

  def product_barcode
    feature_item.barcode
  end

  def back_request
    salesman_returns.count > 0
  end

  private

  def set_defaults
    self.sum_price = if price.present? && quantity.present?
                       price * quantity
                     else
                       0
                     end
  end

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
    self.remainder = ProductBalance.balance(product_id, feature_item_id) + (quantity_was.presence || 0) if product_id.present? && feature_item_id.present?
  end

  def create_exchange(method)
    if self.product_sale.main_status_id == 4 #exchange
      if method == "update"
        sale_exchange = ProductSaleExchange.create(e_type: 0,
                                                   product_sale_id: product_sale_id_was,
                                                   product_id: product_id_was,
                                                   feature_item_id: feature_item_id_was,
                                                   quantity: quantity_was,
                                                   price: price_was,
                                                   sum_price: sum_price_was,
                                                   operator: product_sale.operator)
        ProductSaleExchange.create(e_type: 0,
                                   exchange: sale_exchange,
                                   product_sale: product_sale,
                                   product: product,
                                   feature_item: feature_item,
                                   quantity: quantity,
                                   price: self[:price],
                                   sum_price: self[:sum_price],
                                   operator: product_sale.operator)
      else
        method == "delete"
        ProductSaleExchange.create(e_type: method == "create" ? 1 : 2,
                                   product_sale: product_sale,
                                   product: product,
                                   feature_item: feature_item,
                                   quantity: quantity,
                                   price: self[:price],
                                   sum_price: self[:sum_price],
                                   operator: product_sale.operator)
      end
    end
  end

end
