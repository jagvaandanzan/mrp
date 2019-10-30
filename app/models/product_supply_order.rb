class ProductSupplyOrder < ApplicationRecord
  belongs_to :supplier, -> {with_deleted}, :class_name => "ProductSupplier"
  belongs_to :user

  has_many :product_supply_order_items, dependent: :destroy

  accepts_nested_attributes_for :product_supply_order_items, allow_destroy: true

  before_save :set_sum_price

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
    items = items.joins(:product_supply_order_items).distinct
    items = items.where('is_closed = false')
    items
  }

  def exchange_value
    ApplicationController.helpers.get_f(self[:exchange_value])
  end

  def code_with_info
    "Захиалга - #{self.code}"
  end

  private

  def set_sum_price
    sum = 0
    product_supply_order_items.each do |item|
      sum += item.quantity * item.price
    end
    self.sum_price = sum * self.exchange_value

    self.closed_date = Time.current unless closed_date.present? && is_closed=='_no'
  end

end
