class ProductSaleItem < ApplicationRecord
  belongs_to :product_sale
  belongs_to :product
  belongs_to :feature_item, :class_name => "ProductFeatureItem"

  has_one :product_balance, :class_name => "ProductBalance", :foreign_key => "sale_item_id", dependent: :destroy
  has_one :salesman_travel, through: :product_sale

  before_save :set_defaults
  before_save :set_product_balance
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

  def send_notification(user, quantity)
    salesman = salesman_travel.salesman
    notification = Notification.create(salesman: salesman,
                                       salesman_travel: salesman_travel,
                                       product_sale_item: self,
                                       title: I18n.t("api.back_product"),
                                       body_s: I18n.t("api.body.back_product_s", user: user.name, product: "#{product.n_name} #{feature_item.name}", quantity: quantity),
                                       body_u: I18n.t("api.body.back_product_u", user: salesman.name, product: "#{product.n_name} #{feature_item.name}", quantity: quantity))
    ApplicationController.helpers.send_noti_salesman(salesman,
                                                     ApplicationController.helpers.push_options('back_product',
                                                                                                self.id,
                                                                                                notification.title,
                                                                                                notification.body_s))
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

end
