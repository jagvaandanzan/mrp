class ShippingErFeature < ApplicationRecord
  belongs_to :shipping_er_product
  belongs_to :product
  belongs_to :supply_feature, class_name: 'ProductSupplyFeature'
  has_many :shipping_ub_features

  validates :quantity, presence: true
  validates_numericality_of :quantity, less_than_or_equal_to: Proc.new(&:remainder)

  attr_accessor :remainder

  scope :by_order_item_id, ->(order_item_id) {
    joins(:supply_feature)
        .where('product_supply_features.order_item_id = ?', order_item_id)
  }

  scope :find_to_ub, -> {
    left_joins(:shipping_ub_features)
        .group("shipping_er_features.id")
        .having("SUM(shipping_ub_features.quantity) IS NULL OR SUM(shipping_ub_features.quantity) < shipping_er_features.quantity")
        .select("shipping_er_features.*, shipping_er_features.quantity - IFNULL(SUM(shipping_ub_features.quantity), 0) as remainder")
  }

end
