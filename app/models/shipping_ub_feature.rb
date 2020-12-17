class ShippingUbFeature < ApplicationRecord
  belongs_to :shipping_ub_product
  belongs_to :shipping_er_feature
  belongs_to :product
  belongs_to :supply_feature, class_name: 'ProductSupplyFeature'

  has_many :product_income_items, dependent: :destroy
  has_one :feature_item, through: :supply_feature

  scope :find_to_incomes, -> {
    left_joins(:product_income_items)
        .group("shipping_ub_features.id")
        .having("SUM(product_income_items.quantity) IS NULL OR SUM(product_income_items.quantity) < shipping_ub_features.quantity")
        .select("shipping_ub_features.*, shipping_ub_features.quantity - IFNULL(SUM(product_income_items.quantity), 0) as remainder")
  }

end