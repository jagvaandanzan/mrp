class ShippingUbFeature < ApplicationRecord
  belongs_to :shipping_ub_product
  belongs_to :shipping_er_feature
  belongs_to :product
  belongs_to :supply_feature, class_name: 'ProductSupplyFeature'

  has_many :product_income_items, dependent: :destroy
  has_one :feature_item, through: :supply_feature

  scope :find_to_incomes, ->(shipping_ub_feature_ids = nil) {
    items = left_joins(:product_income_items)
                .group("shipping_ub_features.id")

    if shipping_ub_feature_ids.nil? || !shipping_ub_feature_ids.present?
      items = items.having("SUM(product_income_items.quantity) IS NULL OR SUM(product_income_items.quantity) < shipping_ub_features.quantity")
    else
      items = items.having("SUM(product_income_items.quantity) IS NULL OR (SUM(product_income_items.quantity) < shipping_ub_features.quantity OR shipping_ub_features.id IN (?))", shipping_ub_feature_ids)
    end

    items.select("shipping_ub_features.*, shipping_ub_features.quantity - IFNULL(SUM(product_income_items.quantity), 0) as remainder")
  }

  scope :by_ids, ->(ids) {
    where("id IN (?)", ids)
  }

  scope :by_quantity, ->(q) {
    where("shipping_ub_features.quantity > ? ", q)
  }

  scope :not_income, ->() {
    left_joins(:product_income_items)
        .group("shipping_ub_features.id")
        .having("SUM(product_income_items.quantity) IS NULL OR SUM(product_income_items.quantity) < shipping_ub_features.quantity")
        .select("shipping_ub_features.*, shipping_ub_features.quantity - IFNULL(SUM(product_income_items.quantity), 0) as remainder")
  }

  scope :by_shipping_er_feature, ->(shipping_er_feature_id) {
    where(shipping_er_feature_id: shipping_er_feature_id)
  }

  scope :quantity, ->(id){
    where(supply_feature_id: id).pluck(:quantity).sum
  }
end