class ShippingErProduct < ApplicationRecord
  belongs_to :shipping_er
  belongs_to :product

  has_many :shipping_er_features, dependent: :destroy
  has_many :shipping_ub_products, dependent: :destroy
  accepts_nested_attributes_for :shipping_er_features, allow_destroy: true

  validates :quantity, :cargo, presence: true

  attr_accessor :remainder

  scope :find_to_ub, -> (id = nil) {
    items = left_joins(:shipping_ub_products)
                .group("shipping_er_products.id")
                .having("SUM(shipping_ub_products.quantity) IS NULL OR SUM(shipping_ub_products.quantity) < shipping_er_products.quantity")
                .select("shipping_er_products.*, shipping_er_products.quantity - IFNULL(SUM(shipping_ub_products.quantity), 0) as remainder")
    items = items.where(id: id) unless id.nil?
    items
  }

  def product_bought
    ProductSupplyFeature.by_product_id(product_id)
        .sum(:quantity)
  end
end