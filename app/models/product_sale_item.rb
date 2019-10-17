class ProductSaleItem < ApplicationRecord
  belongs_to :product_sale
  belongs_to :product
  belongs_to :product_feature_rel

  before_save :set_defaults

  validates :product_id, :product_feature_rel_id, :price, :quantity, presence: true
  validates :quantity, :price, numericality: {greater_than: 0}

  def price
    ApplicationController.helpers.get_f(self[:price])
  end

  def sum_price
    ApplicationController.helpers.get_f(self[:sum_price])
  end


  private

  def set_defaults
    self.sum_price = if price.present? && quantity.present?
                       price * quantity
                     else
                       0
                     end
  end
end
