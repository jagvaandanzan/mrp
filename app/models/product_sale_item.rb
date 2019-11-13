class ProductSaleItem < ApplicationRecord
  belongs_to :product_sale
  belongs_to :product
  belongs_to :feature_rel, :class_name => "ProductFeatureRel"
  belongs_to :feature_item, :class_name => "ProductFeatureItem"

  has_one :product_balance, :class_name => "ProductBalance", :foreign_key => "sale_item_id", dependent: :destroy

  before_save :set_defaults
  before_save :set_product_balance
  before_validation :set_feature_rel
  validates :product_id, :feature_item_id, :price, :quantity, presence: true
  validates :quantity, :price, numericality: {greater_than: 0}
  validates_numericality_of :quantity, less_than_or_equal_to: Proc.new(&:remainder)

  before_validation :set_remainder
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
          operator: product_sale.created_operator,
          quantity: -quantity)
    else
      self.product_balance = ProductBalance.create(product: product,
                                                   feature_item: feature_item,
                                                   operator: product_sale.created_operator,
                                                   quantity: -quantity)
    end
  end

  def set_remainder
    self.remainder = ProductBalance.balance(product_id, feature_item_id) + (quantity_was.presence || 0) if product_id.present? && feature_item_id.present?
  end

  def set_feature_rel
    self.feature_rel_id = feature_item.feature_rel_id if feature_item_id.present?
  end
end
