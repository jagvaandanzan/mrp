class ProductIncomeItem < ApplicationRecord
  belongs_to :product_income
  belongs_to :supply_order_item, :class_name => "ProductSupplyOrderItem"
  belongs_to :product
  belongs_to :product_supplier
  belongs_to :feature_rel, :class_name => "ProductFeatureRel"
  belongs_to :feature_item, :class_name => "ProductFeatureItem"
  has_many :income_locations, :class_name => "ProductIncomeLocation", :foreign_key => "income_item_id", dependent: :destroy

  has_one :product_income_balance, :class_name => "ProductIncomeBalance", :foreign_key => "income_item_id", dependent: :destroy
  has_one :product_balance, :class_name => "ProductBalance", :foreign_key => "income_item_id", dependent: :destroy

  accepts_nested_attributes_for :income_locations, allow_destroy: true

  before_save :set_product_balance
  before_save :set_sum_price

  before_validation :set_remainder
  before_validation :set_defaults

  validates :supply_order_item_id, :product_supplier, :feature_item_id, :quantity, :price, :urgent_type, :date, presence: true
  validates :quantity, :price, numericality: {greater_than: 0}
  validates_numericality_of :quantity, less_than_or_equal_to: Proc.new(&:remainder)
  validate :income_locations_count_check

  attr_accessor :remainder

  enum urgent_type: {engiin: 0, yaaraltai: 1}

  scope :search, ->(start, finish, income_code, supply_code, product_name, type) {
    items = income_date_desc
    items = items.where('? <= date AND date <= ?', start.to_time, finish.to_time + 1.days) if start.present? && finish.present?
    items = items.joins(:product_income).where('product_incomes.code LIKE :value', value: "%#{income_code}%") if income_code.present?
    items = items.joins(supply_order_item: :product_supply_order).where('product_supply_orders.code LIKE :value', value: "%#{supply_code}%") if supply_code.present?
    items = items.joins(:product).where('products.code LIKE :value OR products.name LIKE :value', value: "%#{product_name}%") if product_name.present?
    items = items.where('urgent_type = ?', ProductIncomeItem.urgent_types[type]) if type.present?
    items
  }

  scope :income_date_desc, -> {
    order(date: :desc)
  }

  scope :total_ordered_supply_item, ->(supply_order_item_id) {
    where(supply_order_item_id: supply_order_item_id).sum(:quantity)
  }


  def get_balance
    ProductIncomeBalance.balance(product_id)
  end

  def get_currency(value)
    ApplicationController.helpers.get_currency(value, Const::CURRENCY[supply_order_item.product_supply_order.exchange_before_type_cast.to_i], 0)
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
          feature_item: feature_item,
          user: product_income.user,
          quantity: quantity
      )
    else
      self.product_balance = ProductBalance.create(product: supply_order_item.product,
                                                   feature_item: feature_item,
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

    self.feature_rel_id = feature_item.feature_rel_id if feature_item_id.present?
  end

  def set_sum_price
    self.sum_price = price * quantity
    self.sum_price += shuudan if shuudan.present?

    self.sum_tug = self.sum_price * supply_order_item.product_supply_order.exchange_value
  end

end
