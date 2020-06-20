class ProductSupplyFeature < ApplicationRecord
  belongs_to :order_item, :class_name => "ProductSupplyOrderItem"
  belongs_to :feature_item, :class_name => "ProductFeatureItem"
  has_one :product_income_balance, :class_name => "ProductIncomeBalance", :foreign_key => "supply_feature_id", dependent: :destroy

  attr_accessor :is_create
  with_options :if => Proc.new {|m| m.is_create.present?} do
    validates :quantity, :price, presence: true
    before_save :set_product_balance
    before_save :set_sum_price
  end

  def price
    ApplicationController.helpers.get_f(self[:price])
  end

  def get_currency(value)
    ApplicationController.helpers.get_currency(value, Const::CURRENCY[get_model.exchange_before_type_cast.to_i], 0)
  end

  private

  def get_model
    if order_item.product_supply_order.present?
      order_item.product_supply_order
    else
      order_item.product_sample
    end
  end

  def get_user
    if order_item.product_supply_order.present?
      order_item.product_supply_order.user
    else
      order_item.product_sample.user
    end
  end

  def set_sum_price
    self.sum_price = (price * quantity).to_f.round(1)
  end

  def set_product_balance
    if product_income_balance.present?
      self.product_income_balance.update(
          quantity: quantity
      )
    else
      self.product_income_balance = ProductIncomeBalance.create(product: order_item.product,
                                                                feature_item: feature_item,
                                                                user_supply: get_user,
                                                                quantity: quantity)
    end
  end
end
