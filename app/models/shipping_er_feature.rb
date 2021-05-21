class ShippingErFeature < ApplicationRecord
  belongs_to :shipping_er_product
  belongs_to :product
  belongs_to :supply_feature, class_name: 'ProductSupplyFeature'
  has_many :shipping_ub_features, class_name: "ShippingUbFeature", primary_key: "supply_feature_id", foreign_key: "supply_feature_id", dependent: :destroy

  validates :quantity, presence: true
  validates_numericality_of :quantity, less_than_or_equal_to: Proc.new(&:remainder)

  attr_accessor :remainder

  scope :by_order_item_id, ->(order_item_id) {
    joins(:supply_feature)
        .where('product_supply_features.order_item_id = ?', order_item_id)
  }

  scope :by_order_item, ->(order_item_id) {
    items = joins(:shipping_er_product)
    items = items.joins(:supply_feature)
              .where('product_supply_features.order_item_id IN (?)', order_item_id)
    items
  }

  scope :not_in_ub, ->{
    joins(:shipping_ub_features, :supply_feature)
  }


  scope :ship_ub, ->{
    items = left_joins(:shipping_ub_features)
              .where("shipping_ub_features.supply_feature_id IS not NULL")
    items = items.joins(:supply_feature)
    items
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

  scope :by_date, ->(start, finish) {
    where('? <= shipping_er_features.updated_at AND shipping_er_features.updated_at <= ?', start.to_time, finish.to_time + 1.days)
  }

  scope :sum_quantity, ->(er_feature_id) {
    where(supply_feature_id: er_feature_id)
        .sum(:quantity)
  }

  scope :by_supply_feature_ids, -> (ids) {
    where("supply_feature_id IN (?)", ids)
  }

  scope :quantity, ->(id){
    where(supply_feature_id: id).pluck(:quantity).sum
  }

end
