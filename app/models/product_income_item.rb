class ProductIncomeItem < ApplicationRecord
  before_save :update_supply_order_item_remainder

  belongs_to :income, :class_name => "ProductIncome"
  belongs_to :supply_order_item, :class_name => "ProductSupplyOrderItem"
  belongs_to :feature_rel, :class_name => "ProductFeatureRel"
  belongs_to :user
  has_many :income_locations, :class_name => "ProductIncomeLocation", :foreign_key => "income_item_id", dependent: :destroy

  has_one :product_income_balance, :class_name => "ProductIncomeBalance", :foreign_key => "income_item_id", dependent: :destroy
  has_one :product_balance, :class_name => "ProductBalance", :foreign_key => "income_item_id", dependent: :destroy
  before_save :set_product_balance

  validates :income_id, :supply_order_item_id, :feature_rel_id, :urgent_type, :quantity, :price, presence: true
  validates :quantity, :price, numericality: {greater_than: 0}
  validates_numericality_of :quantity, less_than_or_equal_to: Proc.new(&:remainder)
  before_validation :set_remainder
  validate :income_locations_count_check

  accepts_nested_attributes_for :income_locations, allow_destroy: true

  attr_accessor :remainder

  enum urgent_type: {engiin: 0, yaaraltai: 1}

  scope :search, ->(income_id, sname, scode, stype) {
    # items = created_at_desc
    items = where(income_id: income_id)
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
    if (self.quantity || 0) < s
      errors.add(:income_locations, :over)
    end
  end

  def set_product_balance
    if product_balance.present?
      self.product_balance.update(
          product: supply_order_item.product,
          feature_rel: feature_rel,
          user: user,
          quantity: quantity
      )
    else
      self.product_balance = ProductBalance.create(product: supply_order_item.product,
                                                   feature_rel: feature_rel,
                                                   user: user,
                                                   quantity: quantity)
    end

    if product_income_balance.present?
      self.product_income_balance.update(
          product: supply_order_item.product,
          user_income: user,
          quantity: -quantity)
    else
      self.product_income_balance = ProductIncomeBalance.create(product: supply_order_item.product,
                                                                user_income: user,
                                                                quantity: -quantity)
    end

  end

  def set_remainder
    self.remainder = ProductIncomeBalance.balance(self.supply_order_item.product_id) + (quantity_was.presence || 0)
  end
end
