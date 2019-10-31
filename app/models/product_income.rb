class ProductIncome < ApplicationRecord
  belongs_to :user
  has_many :product_income_items, dependent: :destroy

  accepts_nested_attributes_for :product_income_items, allow_destroy: true

  before_save :set_sum_price

  validates :code, presence: true
  validates :code, uniqueness: true
  validate :valid_quantity

  scope :income_date_desc, -> {
    order(income_date: :desc)
  }

  scope :search, ->(code, start, finish) {
    items = income_date_desc
    items = items.where('code LIKE :value', value: "%#{code}%") if code.present?
    items = items.where('DATE(income_date) >= :s AND DATE(income_date) <= :f', s: "#{start}", f: "#{finish}") if start.present? && finish.present?
    items
  }

  private

  def set_sum_price
    sum = 0
    product_income_items.each do |item|
      sum += item.supply_order_item.product_supply_order.exchange_value * (item.quantity * item.price)
    end

    self.sum_price = sum
  end

  def valid_quantity
    remainder = Hash.new
    sums = Hash.new

    product_income_items.each do |i|
      if i.supply_order_item.present?
        unless remainder[i.supply_order_item.id].present?
          remainder[i.supply_order_item.id] = ProductIncomeBalance.balance(i.supply_order_item.product_id)
          sums[i.supply_order_item.id] = 0
        end
        sums[i.supply_order_item.id] += (i.quantity - (i.quantity_was.presence || 0))
      end
    end

    remainder.each do |key, value|
      if value < sums[key]
        self.errors.add(:product_income_items, :over_quantity)
      end
    end
  end
end
