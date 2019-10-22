class ProductIncomeBalance < ApplicationRecord
  acts_as_paranoid

  belongs_to :product
  belongs_to :supply_order_item, :class_name => "ProductSupplyOrderItem", optional: true
  belongs_to :income_item, :class_name => "ProductIncomeItem", optional: true
  belongs_to :user_supply, :class_name => "User", optional: true
  belongs_to :user_income, :class_name => "User", optional: true

  scope :balance, -> (product_id) {
    where(product_id: product_id)
        .sum(:quantity)
  }

end
