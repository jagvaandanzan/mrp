class ProductSupplyOrder < ApplicationRecord
  belongs_to :supplier, :class_name => "ProductSupplier"
  has_many :items, :class_name => "ProductSupplyOrderItem", :foreign_key => "supply_order_id"

  validates :supplier_id, :code, :payment, :exchange, :exchange_value, presence: true

  enum payment: {belneer: 0, zeeleer: 1}
  enum exchange: {cny: 0, usd: 1, eur: 2, rub:3, jpy:4, gbr: 5, mnt:6 }
end
