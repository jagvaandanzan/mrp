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

  scope :find_to_ub, ->(not_er_feature_ids = nil) {
    items = left_joins(:shipping_ub_features)
                .group("shipping_er_features.id")
    if not_er_feature_ids.nil? || !not_er_feature_ids.present?
      items = items.having("SUM(shipping_ub_features.quantity) IS NULL OR SUM(shipping_ub_features.quantity) < shipping_er_features.quantity")
    else
      items = items.having("SUM(shipping_ub_features.quantity) IS NULL OR (SUM(shipping_ub_features.quantity) < shipping_er_features.quantity OR shipping_er_features.id IN (?))", not_er_feature_ids)
    end
    items.select("shipping_er_features.*, shipping_er_features.quantity - IFNULL(SUM(shipping_ub_features.quantity), 0) as remainder")
  }

  scope :sum_quantity, ->(er_feature_id) {
    where(supply_feature_id: er_feature_id)
        .sum(:quantity)
  }

  scope :by_supply_feature_ids, -> (ids) {
    where("supply_feature_id IN (?)", ids)
  }

end
