class ProductSaleReturn < ApplicationRecord
  belongs_to :product_sale
  belongs_to :product_sale_item
  has_one :salesman_travel, through: :product_sale

  has_one :product_balance, :class_name => "ProductBalance", :foreign_key => "salesman_return_id", dependent: :destroy

  attr_accessor :remainder

  validates_numericality_of :quantity, less_than_or_equal_to: Proc.new(&:remainder)
  validates :quantity, numericality: {greater_than: 0}

  def price
    ApplicationController.helpers.get_f(product_sale_item.price)
  end

  def bought_quantity
    product_sale_item.bought_quantity
  end

  def product_image
    product_sale_item.feature_item.img
  end

  def product_feature
    product_sale_item.feature_item.name
  end

  def product_name
    product_sale_item.product.name
  end

  def product_code
    product_sale_item.product.code
  end

  def product_barcode
    product_sale_item.feature_item.barcode
  end

  def exchange_balance
    product = product_sale_item.product
    feature_item = product_sale_item.feature_item
    ProductBalance.create(sale_item: product_sale_item,
                          product: product,
                          feature_item: feature_item,
                          quantity: take_quantity)
    upt_back_money = self.product_sale.back_money + ((quantity - take_quantity) * product_sale_item.price)
    product_sale_item.product_sale.update_column(:back_money, upt_back_money) if upt_back_money != product_sale_item.product_sale.back_money
  end

  def remove_bonus
    if take_quantity.present?
      bonu = Bonu.by_phone(product_sale.phone)
      b_model = if bonu.present?
                  bonu.first
                else
                  b = Bonu.new(balance: 0)
                  b.bonus_phones << BonusPhone.new(phone: product_sale.phone)
                  b.save
                  b
                end
      if product_sale_item.bonus_balance.present?
        product_sale_item.bonus_balance.update(bonu: b_model, bonus: -ApplicationController.helpers.get_percentage(take_quantity * product_sale_item.price, 5))
      else
        BonusBalance.create(bonu: b_model, product_sale_item: product_sale_item, bonus: -ApplicationController.helpers.get_percentage(take_quantity * price, 5))
      end
    end
  end

end
