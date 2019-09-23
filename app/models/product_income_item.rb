class ProductIncomeItem < ApplicationRecord
  belongs_to :income, :class_name => "ProductIncome"
  belongs_to :supply_order_item, :class_name => "ProductSupplyOrderItem"
  belongs_to :location, -> { with_deleted }, :class_name => "ProductLocation", optional: true
  has_many :income_feature_rels, :class_name => "ProductIncomeFeatureRel", :foreign_key => "income_item_id", dependent: :destroy

  validates :income_id, :supply_order_item_id, :urgent_type, :quantity, :price, presence: true

  accepts_nested_attributes_for :income_feature_rels, allow_destroy: true

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

end
