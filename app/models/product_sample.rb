class ProductSample < ApplicationRecord
  acts_as_paranoid

  belongs_to :supplier, -> {with_deleted}, :class_name => "ProductSupplier"
  belongs_to :user

  has_many :product_supply_order_items
  accepts_nested_attributes_for :product_supply_order_items, allow_destroy: true

  attr_accessor :tab_index

  validates :supplier_id, :code, :payment, :exchange, :exchange_value, presence: true
  validates :code, uniqueness: true

  enum payment: {belneer: 0, zeeleer: 1}
  enum exchange: {cny: 0, usd: 1, eur: 2, rub: 3, jpy: 4, gbr: 5, mnt: 6}

  scope :created_at_desc, -> {
    order(created_at: :desc)
  }

  scope :search, ->(code, start, finish) {
    items = created_at_desc
    items = items.where('code LIKE :value', value: "%#{code}%") if code.present?
    items = items.where('ordered_date >= :s AND ordered_date <= :f', s: "#{start}", f: "#{finish}") if start.present? && finish.present?
    items
  }
  def exchange_value
    ApplicationController.helpers.get_f(self[:exchange_value])
  end

end