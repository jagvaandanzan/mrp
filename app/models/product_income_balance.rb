class ProductIncomeBalance < ApplicationRecord
  acts_as_paranoid

  belongs_to :product
  belongs_to :feature_item, :class_name => "ProductFeatureItem"
  belongs_to :supply_feature, :class_name => "ProductSupplyFeature", optional: true
  belongs_to :income_item, :class_name => "ProductIncomeItem", optional: true
  belongs_to :user_supply, :class_name => "User", optional: true
  belongs_to :user_income, :class_name => "User", optional: true

  scope :balance, -> (product_id) {
    where(product_id: product_id)
        .sum(:quantity)
  }

end
