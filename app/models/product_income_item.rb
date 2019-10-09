class ProductIncomeItem < ApplicationRecord
  before_save :update_supply_order_item_remainder

  belongs_to :income, :class_name => "ProductIncome"
  belongs_to :supply_order_item, :class_name => "ProductSupplyOrderItem"
  belongs_to :product_feature_rel, :class_name => "ProductFeatureRel", optional: true
  has_many :income_locations, :class_name => "ProductIncomeLocation", :foreign_key => "income_item_id", dependent: :destroy

  validates :income_id, :supply_order_item_id, :urgent_type, :quantity, :price, presence: true

  validates :quantity, :price, numericality: {greater_than: 0}

  validate :total_must_be_less_than_remainder

  validate :income_locations_count_check

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
    quantity_prev = self.quantity_was || 0
    remainder = ProductSupplyOrderItem.get_remainder(supply_order_item_id) + quantity_prev
    current_total = ProductIncomeItem.total_ordered_supply_item(supply_order_item_id) - quantity_prev
    if remainder < current_total + self.quantity
      errors.add(:quantity, :greater_than_or_equal_to, count: remainder)
    end
  end

  def update_supply_order_item_remainder
    quantity_prev = self.quantity_was || 0
    remainder = ProductSupplyOrderItem.get_remainder(supply_order_item_id) + quantity_prev - (self.quantity || 0)
    ProductSupplyOrderItem.find(supply_order_item.id).update_column(:remainder, remainder)
  end

  def income_locations_count_check
    s = 0
    self.income_locations.each do |location|
      lq = location.quantity
      if lq < 0
        errors.add(:income_locations, :greater_than, count: 0)
        return
      end
      s += location.quantity
    end
    if quantity < s
      errors.add(:income_locations, :over)
    end
  end
end
