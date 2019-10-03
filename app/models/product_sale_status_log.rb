class ProductSaleStatusLog < ApplicationRecord
  belongs_to :product_sale, :class_name => "ProductSale", optional: true
  belongs_to :operator, :class_name => "Operator", optional: true
  belongs_to :status, :class_name => "ProductSaleStatus", optional: true


end
