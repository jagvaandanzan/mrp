class ShippingErProduct < ApplicationRecord
  belongs_to :supply_order, :class_name => "ProductSupplyOrder"
  belongs_to :shipping_er
  belongs_to :product

  has_many :shipping_er_features, dependent: :destroy
  has_many :shipping_ub_products, dependent: :destroy
  accepts_nested_attributes_for :shipping_er_features, allow_destroy: true

  validates :quantity, :cargo, presence: true

  attr_accessor :remainder


  scope :find_to_ub, -> (id = nil, by_product_name) {
    items = left_joins(:shipping_ub_products)
                .group("shipping_er_products.id")
                .having("SUM(shipping_ub_products.quantity) IS NULL OR SUM(shipping_ub_products.quantity) < shipping_er_products.quantity")
                .select("shipping_er_products.*, shipping_er_products.quantity - IFNULL(SUM(shipping_ub_products.quantity), 0) as remainder")
    items = items.where(id: id) unless id.nil?
    items = items.left_joins(:product).where('products.code LIKE :value OR products.n_name LIKE :value OR products.c_name LIKE :value', value: "%#{by_product_name}%") if by_product_name.present?
    items
  }


  scope :by_date, ->(start, finish) {
    where('? <= shipping_er_products.created_at AND shipping_er_products.created_at <= ?', start.to_time, finish.to_time + 1.days)
  }


  def product_bought
    ProductSupplyFeature.by_product_id(product_id)
        .sum(:quantity)
  end
end