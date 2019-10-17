class ProductSupplyOrderItem < ApplicationRecord
  before_save :set_remainder

  belongs_to :supply_order, :class_name => "ProductSupplyOrder"
  belongs_to :product, -> { with_deleted }
  has_many :income_items, :class_name => "ProductIncomeItem", :foreign_key => "supply_order_item_id", dependent: :destroy

  validates :supply_order_id, :product_id, :quantity, :price, presence: true

  validate :quantity_greater_than_total_ordered_supply

  scope :order_by_date, -> {
    order(:created_at)
  }

  scope :search, ->(order_id, sname) {
    items = where(supply_order_id: order_id)

    items = items.joins(:product)
    items = items.where('products.code LIKE :value OR products.name LIKE :value', value: "%#{sname}%") if sname.present?
    items.order("products.name")
  }

  scope :get_remainder, ->(order_id) {
    where(id: order_id).sum("remainder")
  }

  def product_name_with_code
    "#{self.product.code} - #{self.product.name}"
  end

  private

  def quantity_greater_than_total_ordered_supply
    t = ProductIncomeItem.total_ordered_supply_item(self.id)
    if self.quantity.present? && t.floor > self.quantity.floor
      errors.add(:quantity, "は #{t} 以上の値にしてください")
    end
  end

  def set_remainder
    t = ProductIncomeItem.total_ordered_supply_item(self.id)
    self.remainder = self.quantity - t
  end
end
