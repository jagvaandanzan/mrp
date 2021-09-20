class ProductSaleLog < ApplicationRecord
  belongs_to :operator, -> {with_deleted}
  belongs_to :salesman, -> {with_deleted}, optional: true
  belongs_to :salesman_travel, optional: true
  belongs_to :user, -> {with_deleted}, optional: true
  belongs_to :log_stat, optional: true
  belongs_to :product_sale, -> {with_deleted}
  belongs_to :sale_item, -> {with_deleted}, :class_name => "ProductSaleItem", optional: true

  belongs_to :product, -> {with_deleted}, optional: true
  belongs_to :feature_item, -> {with_deleted}, :class_name => "ProductFeatureItem", optional: true
  belongs_to :o_product, -> {with_deleted}, :class_name => "Product", optional: true
  belongs_to :o_feature_item, -> {with_deleted}, :class_name => "ProductFeatureItem", optional: true
end
