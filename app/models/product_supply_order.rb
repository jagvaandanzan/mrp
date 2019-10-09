class ProductSupplyOrder < ApplicationRecord
  belongs_to :supplier, -> {with_deleted}, :class_name => "ProductSupplier"
  has_many :items, :class_name => "ProductSupplyOrderItem", :foreign_key => "supply_order_id", dependent: :destroy

  validates :supplier_id, :code, :payment, :exchange, :exchange_value, presence: true
  validates :code, uniqueness: true

  enum payment: {belneer: 0, zeeleer: 1}
  enum is_closed: {_no: 0, _yes: 1}
  enum exchange: {cny: 0, usd: 1, eur: 2, rub: 3, jpy: 4, gbr: 5, mnt: 6}

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

  scope :searchNotClosed, ->() {
    items = created_at_desc
    items = items.joins(:items).distinct
    items = items.where('is_closed = false')
    items
  }

  def sum_price
    sum_price = items.sum("quantity*price")
    sum_price * self.exchange_value
  end

  def code_with_info
    "Захиалга - #{self.code}"
  end
end
