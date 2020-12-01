class SalesmanReturn < ApplicationRecord
  belongs_to :sign, :class_name => "SalesmanReturnSign", optional: true
  belongs_to :salesman
  belongs_to :user, optional: true
  belongs_to :product
  belongs_to :feature_item, :class_name => "ProductFeatureItem"
  belongs_to :sale_item, :class_name => "ProductSaleItem"

  scope :by_sale_item_salesman, ->(si_id, salesman_id) {
    joins(:sign)
        .where("salesman_return_signs.user_id IS ?", nil)
        .where(sale_item_id: si_id)
        .where(salesman_id: salesman_id)
  }

  scope :by_salesman, ->(salesman_id) {
    where(salesman_id: salesman_id)
  }

  scope :by_sign, ->(sign_id) {
    where(sign_id: sign_id)
  }

  scope :by_user, ->(user_id) {
    where(user_id: user_id)
  }

  def product_image
    feature_item.img
  end

  def product_feature
    feature_item.name
  end

  def product_name
    product.name
  end

  def product_code
    product.code
  end

  def product_barcode
    feature_item.barcode
  end

end
