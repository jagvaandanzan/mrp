class ProductSaleDirect < ApplicationRecord
  acts_as_paranoid

  belongs_to :salesman
  belongs_to :product
  belongs_to :feature_rel, :class_name => "ProductFeatureRel"
  belongs_to :feature_item, :class_name => "ProductFeatureItem"
  belongs_to :sale_item, :class_name => "ProductSaleItem"

  has_one :product_balance, :class_name => "ProductBalance", :foreign_key => "sale_direct_id", dependent: :destroy

  before_save :set_defaults
  before_save :set_product_balance
  validates :product_id, :feature_item_id, :price, :quantity, presence: true
  validates :quantity, :price, numericality: {greater_than: 0}
  validates_numericality_of :quantity, less_than_or_equal_to: Proc.new(&:remainder)
  validates :phone, numericality: {greater_than_or_equal_to: 80000000, less_than_or_equal_to: 99999999, only_integer: true, message: :invalid}

  attr_accessor :remainder

  def price
    ApplicationController.helpers.get_f(self[:price])
  end

  def sum_price
    ApplicationController.helpers.get_f(self[:sum_price])
  end

  def get_balance
    ProductBalance.balance(product_id, feature_item_id)
  end

  def product_image
    feature_rel.image
  end

  def product_size
    feature_item.name
  end

  private

  def set_defaults
    self.sum_price = if price.present? && quantity.present?
                       price * quantity
                     else
                       0
                     end
  end

  def set_product_balance
    if product_balance.present?
      self.product_balance.update(
          product: product,
          feature_item: feature_item,
          quantity: -quantity)
    else
      self.product_balance = ProductBalance.create(product: product,
                                                   feature_item: feature_item,
                                                   quantity: -quantity)

    end

    sale_item_balances = ProductBalance.by_sale_item(feature_item_id, sale_item_id)
    if sale_item_balances.present?
      sale_item_balance = sale_item_balances.first
      sale_item_quantity = sale_item.quantity - quantity
      Rails.logger.debug("sale_item_quantity==" + sale_item_quantity.to_s)
      if sale_item_quantity == 0
        sale_item_balance.destroy
      else
        sale_item_balance.update_columns(quantity: sale_item_quantity)
      end
    end

    sale_item.update_columns(back_quantity: sale_item.back_quantity.present? ? sale_item.back_quantity + quantity : quantity)
  end

end
