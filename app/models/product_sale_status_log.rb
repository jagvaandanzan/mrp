class ProductSaleStatusLog < ApplicationRecord
  acts_as_paranoid

  belongs_to :product_sale, optional: true
  belongs_to :product_sale_call, optional: true
  belongs_to :operator, optional: true
  belongs_to :salesman, optional: true
  belongs_to :status, :class_name => "ProductSaleStatus"
end
