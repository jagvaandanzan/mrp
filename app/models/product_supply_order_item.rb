class ProductSupplyOrderItem < ApplicationRecord
  belongs_to :supply_order, :class_name => "ProductSupplyOrder"
  belongs_to :product, -> { with_deleted }, :class_name => "Product"
  has_many :income_items, :class_name => "ProductIncomeItem", :foreign_key => "supply_order_item_id", dependent: :destroy


  validates :supply_order_id, :product_id, :quantity, :price, presence: true

  scope :order_by_date, -> {
    order(:created_at)
  }

  scope :search, ->(order_id, sname) {
    items = where(supply_order_id: order_id)

    items = items.joins(:product)
    items = items.where('products.name LIKE :value', value: "%#{sname}%") if sname.present?
    items.order("products.name")
  }


  # scope :search, ->() {
  #   items = items.joins(:product)
  #   items = items.where('products.name LIKE :value', value: "%#{sname}%") if sname.present?
  #   items.order("products.name")
  # }
  #
  def product_name_with_code
    "#{self.product.code} - #{self.product.name}"
  end

end
