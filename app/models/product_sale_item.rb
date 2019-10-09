class ProductSaleItem < ApplicationRecord
  belongs_to :product_sale, :class_name => "ProductSale", optional: true
  belongs_to :product, :class_name => "Product", optional: true
  belongs_to :product_feature_rel, :class_name => "ProductFeatureRel", optional: true

  # Захиалга үүсгэх үед тоо хэмжээг заавал оруулж байж хадгалдаг болгох
  validates :quantity, presence: true

  validates :quantity, numericality: {greater_than: 0}

  def sum_price
    if self.price.present? && self.quantity.present?
      self.price * self.quantity
    else
      0
    end
  end
end
