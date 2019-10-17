class ProductSaleStatusLog < ApplicationRecord
  acts_as_paranoid

  belongs_to :product_sale
  belongs_to :operator
  belongs_to :status, :class_name => "ProductSaleStatus"
end
