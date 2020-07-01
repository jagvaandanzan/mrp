class ProductSupplyOrder < ApplicationRecord
  acts_as_paranoid
  belongs_to :supplier, -> {with_deleted}, :class_name => "ProductSupplier"
  belongs_to :user

  has_many :product_supply_order_items, dependent: :destroy
  accepts_nested_attributes_for :product_supply_order_items, allow_destroy: true
  attr_accessor :tab_index

  validates :supplier_id, :code, :exchange, presence: true
  validates :code, uniqueness: true

  enum status: {order_created: 0, ordered: 1, cost_included: 2, warehouse_received: 3, calculated: 4, clarification: 5, clarified: 6, canceled: 7}
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

  def get_currency(value)
    ApplicationController.helpers.get_currency(value, Const::CURRENCY[exchange_before_type_cast.to_i], 0)
  end

  def code_with_info
    "Захиалга - #{self.code}"
  end

  def get_status
    "#{ordered_date.strftime('%F')} - #{status_i18n} - #{user.name}"
  end

  def update_status(stat)
    # Бүгд дор хаяж тэнцүү болсон үед солино
    exist_items = product_supply_order_items.by_status_lower(stat)
    unless exist_items.present?
      self.update_attributes(status: stat)
    end
  end
end
