class ProductSupplyOrderItem < ApplicationRecord
  belongs_to :supply_order, :class_name => "ProductSupplyOrder"
  belongs_to :product,:class_name => "Product"

  validates :supply_order_id, :product_id, :quantity, :price, presence: true

  scope :order_by_date, -> {
    order(:created_at)
  }

  scope :search, ->() {
    items = order_by_date
    # items = items.where('name LIKE :value', value: "%#{sname}%") if sname.present?
    items
  }

end
