class SalesmanReturn < ApplicationRecord
  belongs_to :sign, :class_name => "SalesmanReturnSign", optional: true
  belongs_to :salesman
  belongs_to :user, optional: true
  belongs_to :product
  belongs_to :feature_item, :class_name => "ProductFeatureItem"
  belongs_to :sale_item, :class_name => "ProductSaleItem"
  has_one :product_balance, dependent: :destroy

  scope :by_sale_item_salesman, ->(si_id, salesman_id) {
    left_joins(:sign)
        .where("salesman_return_signs.id IS NULL OR salesman_return_signs.user_id IS ?", nil)
        .where(sale_item_id: si_id)
        .where(salesman_id: salesman_id)
  }

  scope :by_salesman, ->(salesman_id) {
    where(salesman_id: salesman_id)
  }

  scope :by_sign_user, ->(user_id) {
    items = left_joins(:sign)
    if user_id.nil?
      items = items.where("salesman_return_signs.id IS NULL OR salesman_return_signs.user_id IS ?", nil)
    else
      items = items.where("salesman_return_signs.user_id = ?", user_id)
    end
    items
  }

  scope :by_user, ->(user_id) {
    where(user_id: user_id)
  }
  scope :date_by_quantity, ->(date) {
    select("salesman_id, salesmen.name as salesman_name, SUM(quantity) as quantity")
        .joins(:salesman)
        .where('? <= salesman_returns.created_at AND salesman_returns.created_at < ?', date, date + 1.day)
        .group(:salesman_id)
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
