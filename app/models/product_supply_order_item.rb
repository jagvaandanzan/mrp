class ProductSupplyOrderItem < ApplicationRecord

  belongs_to :product_supply_order
  belongs_to :product, -> {with_deleted}
  has_many :income_items, :class_name => "ProductIncomeItem", :foreign_key => "supply_order_item_id", dependent: :destroy

  has_one :product_income_balance, :class_name => "ProductIncomeBalance", :foreign_key => "supply_order_item_id", dependent: :destroy

  before_save :set_product_balance
  before_save :set_sum_price

  validates :product_id, :quantity, :price, presence: true

  scope :search, ->(start, finish, supply_code, product_name) {
    items = joins(:product_supply_order)
    items = items.where('? <= product_supply_orders.ordered_date AND product_supply_orders.ordered_date <= ?', start.to_time, finish.to_time) if start.present? && finish.present?
    items = items.where('product_supply_orders.code LIKE :value', value: "%#{supply_code}%") if supply_code.present?
    items = items.joins(:product).where('products.code LIKE :value OR products.name LIKE :value', value: "%#{product_name}%") if product_name.present?
    items.order("product_supply_orders.ordered_date": :desc)
    items
  }


  def product_name_with_code
    "#{self.product.code} - #{self.product.name}"
  end

  def price
    ApplicationController.helpers.get_f(self[:price])
  end

  def get_currency(value)
    ApplicationController.helpers.get_currency(value, Const::CURRENCY[product_supply_order.exchange_before_type_cast.to_i], 0)
  end

  private

  def set_sum_price
    self.sum_price = price * quantity
    self.sum_price += shuudan if shuudan.present?

    self.sum_tug = self.sum_price * product_supply_order.exchange_value
  end

  def set_product_balance
    if product_income_balance.present?
      self.product_income_balance.update(
          product: product,
          user_supply: product_supply_order.user,
          quantity: quantity
      )
    else
      self.product_income_balance = ProductIncomeBalance.create(product: product,
                                                                user_supply: product_supply_order.user,
                                                                quantity: quantity)
    end
  end
end
