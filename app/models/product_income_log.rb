class ProductIncomeLog < ApplicationRecord
  belongs_to :product_income_item
  belongs_to :feature_item_was, :class_name => "ProductFeatureItem", optional: true
  belongs_to :feature_item, :class_name => "ProductFeatureItem", optional: true
  belongs_to :owner, :class_name => "User"
  belongs_to :user, optional: true
end
