class ProductIncomeItem < ApplicationRecord
  belongs_to :product_income
  belongs_to :supply_order_item, :class_name => "ProductSupplyOrderItem"
  belongs_to :product
  belongs_to :product_supplier
  belongs_to :feature_rel, :class_name => "ProductFeatureRel"
  has_many :income_locations, :class_name => "ProductIncomeLocation", :foreign_key => "income_item_id", dependent: :destroy

  has_one :product_income_balance, :class_name => "ProductIncomeBalance", :foreign_key => "income_item_id", dependent: :destroy
  has_one :product_balance, :class_name => "ProductBalance", :foreign_key => "income_item_id", dependent: :destroy

  accepts_nested_attributes_for :income_locations, allow_destroy: true

  before_save :set_product_balance

  before_validation :set_remainder
  before_validation :set_defaults

  validates :supply_order_item_id, :product_supplier, :feature_rel_id, :quantity, :price, :urgent_type, :date, presence: true
  validates :quantity, :price, numericality: {greater_than: 0}
  validates_numericality_of :quantity, less_than_or_equal_to: Proc.new(&:remainder)
  validate :income_locations_count_check

  attr_accessor :remainder

  enum urgent_type: {engiin: 0, yaaraltai: 1}

  scope :search, ->(income_id, sname, scode, stype) {
    # items = created_at_desc
    items = where(income_id: income_id)
    items = items.joins(supply_order_item: :product).where("products.name LIKE :value", value: "%#{sname}%") if sname.present?
    items = items.joins(supply_order_item: :product_supply_order)
    items = items.where("product_supply_orders.code LIKE :value", value: "%#{scode}%") if scode.present?
    items = items.where('urgent_type = ?', ProductIncomeItem.urgent_types[stype]) if stype.present?

    items.order("product_supply_orders.code")
  }

  scope :total_ordered_supply_item, ->(supply_order_item_id) {
    where(supply_order_item_id: supply_order_item_id).sum(:quantity)
  }

  def get_balance
    ProductIncomeBalance.balance(product_id)
  end

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
    if product_income_balance.present?
      self.product_income_balance.update(
          product: supply_order_item.product,
          user_income: product_income.user,
          quantity: -quantity)
    else
      self.product_income_balance = ProductIncomeBalance.create(product: supply_order_item.product,
                                                                user_income: product_income.user,
                                                                quantity: -quantity)
    end

    if product_balance.present?
      self.product_balance.update(
          product: supply_order_item.product,
          feature_rel: feature_rel,
          user: product_income.user,
          quantity: quantity
      )
    else
      self.product_balance = ProductBalance.create(product: supply_order_item.product,
                                                   feature_rel: feature_rel,
                                                   user: product_income.user,
                                                   quantity: quantity)
    end

  end

  def set_remainder
    self.remainder = ProductIncomeBalance.balance(supply_order_item.product_id) + (quantity_was.presence || 0) if supply_order_item.present?
  end

  def set_defaults
    if supply_order_item.present?
      self.product = supply_order_item.product
      self.product_supplier = supply_order_item.product_supply_order.supplier
    end
  end
end
