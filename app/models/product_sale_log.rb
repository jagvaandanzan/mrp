class ProductSaleLog < ApplicationRecord
  belongs_to :operator
  belongs_to :product, optional: true
  belongs_to :feature_item, :class_name => "ProductFeatureItem", optional: true
  belongs_to :o_product, :class_name => "Product", optional: true
  belongs_to :o_feature_item, :class_name => "ProductFeatureItem", optional: true
end
