class ProductSupplyOrderItem < ApplicationRecord

  belongs_to :supply_order, :class_name => "ProductSupplyOrder"
  belongs_to :product, -> { with_deleted }
  has_many :income_items, :class_name => "ProductIncomeItem", :foreign_key => "supply_order_item_id", dependent: :destroy

  has_one :product_income_balance, :class_name => "ProductIncomeBalance", :foreign_key => "supply_order_item_id", dependent: :destroy

  before_save :set_product_balance

  validates :supply_order_id, :product_id, :quantity, :price, presence: true

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

  def price
    ApplicationController.helpers.get_f(self[:price])
  end

  private

  def set_product_balance
    if product_income_balance.present?
      self.product_income_balance.update(
          product: product,
          user_supply: supply_order.user,
          quantity: quantity
      )
    else
      self.product_income_balance = ProductIncomeBalance.create(product: product,
                                                         user_supply: supply_order.user,
                                                         quantity: quantity)
    end
  end
end
