class ProductIncomeItem < ApplicationRecord
  before_save :update_supply_order_item_remainder

  belongs_to :income, :class_name => "ProductIncome"
  belongs_to :supply_order_item, :class_name => "ProductSupplyOrderItem"
  belongs_to :product_feature_rel, :class_name => "ProductFeatureRel", optional: true
  has_many :income_locations, :class_name => "ProductIncomeLocation", :foreign_key => "income_item_id", dependent: :destroy

  validates :income_id, :supply_order_item_id, :urgent_type, :quantity, :price, presence: true

  validate :total_must_be_less_than_remainder

  accepts_nested_attributes_for :income_locations, allow_destroy: true

  enum urgent_type: {engiin: 0, yaaraltai: 1}

  scope :search, ->(income_id, sname, scode, stype) {
    # items = created_at_desc
    items = where(income_id: income_id)
    # items = items.joins(:supply_order_item)
    items = items.joins(supply_order_item: :product).where("products.name LIKE :value", value: "%#{sname}%") if sname.present?
    items = items.joins(supply_order_item: :supply_order)
    items = items.where("product_supply_orders.code LIKE :value", value: "%#{scode}%") if scode.present?
    items = items.where('urgent_type = ?', ProductIncomeItem.urgent_types[stype]) if stype.present?

    items.order("product_supply_orders.code")
  }

  scope :total_ordered_supply_item, ->(supply_order_item_id) {
    where(supply_order_item_id: supply_order_item_id).sum(:quantity)
  }

  private
  def total_must_be_less_than_remainder
    remainder = ProductSupplyOrderItem.get_remainder(supply_order_item_id) + self.quantity_was
    current_total = ProductIncomeItem.total_ordered_supply_item supply_order_item_id - self.quantity_was
    if remainder < current_total + self.quantity
      errors.add(:quantity, "は #{remainder} 以上以下の値にしてください")
    end
  end

  def update_supply_order_item_remainder
    remainder = ProductSupplyOrderItem.get_remainder(supply_order_item_id) + self.quantity_was - self.quantity
    ProductSupplyOrderItem.find(supply_order_item.id).update_column(:remainder, remainder)
  end
end
