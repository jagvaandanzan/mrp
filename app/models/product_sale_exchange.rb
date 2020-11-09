class ProductSaleExchange < ApplicationRecord
  belongs_to :product_sale
  belongs_to :exchange, class_name: "ProductSaleExchange", optional: true
  belongs_to :product
  belongs_to :feature_item, class_name: "ProductFeatureItem"
  belongs_to :operator

  has_one :to_exchange, class_name: "ProductSaleExchange", foreign_key: "exchange_id", dependent: :destroy
  enum e_type: {is_exchange: 0, is_add: 1, is_return: 2}

  scope :by_exchange_nil, ->() {
    where("exchange_id IS ?", nil)
  }

end
