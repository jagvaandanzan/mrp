class ProductSupplyOrder < ApplicationRecord
  belongs_to :supplier, :class_name => "ProductSupplier"
  has_many :items, :class_name => "ProductSupplyOrderItem", :foreign_key => "supply_order_id"

  validates :supplier_id, :code, :payment, :exchange, :exchange_value, presence: true

  enum payment: {belneer: 0, zeeleer: 1}
  enum exchange: {cny: 0, usd: 1, eur: 2, rub:3, jpy:4, gbr: 5, mnt:6 }


  scope :created_at_desc, -> {
    order(created_at: :desc)
  }

  scope :search, ->(code, start, finish) {
    items = created_at_desc
    items = items.where('code LIKE :value', value: "%#{code}%") if code.present?
    items = items.where('ordered_date >= :s AND ordered_date <= :f', s: "#{start}", f: "#{finish}") if start.present? && finish.present?
    # items = items.where('payment = :value', value: "%#{payment}%") if payment.present?
    # items = items.where('is_closed = :value', value: close ) if close.present?
    items
  }

  def sumPrice
    @sumPrice = ProductSupplyOrderItem.where('supply_order_id = :value', value: self.id).sum("quantity*price")
    @sumPrice = @sumPrice*self.exchange_value
    @sumPrice
  end
end
