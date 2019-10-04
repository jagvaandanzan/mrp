class ProductSaleStatusPer < ApplicationRecord
  belongs_to :status, :class_name => "ProductSaleStatus", optional: true

  enum user_type: {operator: 0, user: 1, user_admin: 2}
end
