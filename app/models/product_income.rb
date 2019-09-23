class ProductIncome < ApplicationRecord
  belongs_to :supplier, -> { with_deleted }, :class_name => "ProductSupplier"
  has_many :income_items, :class_name => "ProductIncomeItem", :foreign_key => "income_id", dependent: :destroy

  validates :code, :supplier_id, presence: true

  validates :code, uniqueness: true


  scope :income_date_desc, -> {
    order(income_date: :desc)
  }

  scope :search, ->(code, start, finish) {
    items = income_date_desc
    items = items.where('code LIKE :value', value: "%#{code}%") if code.present?
    items = items.where('income_date >= :s AND income_date <= :f', s: "#{start}", f: "#{finish}") if start.present? && finish.present?
    items
  }

  def sumPrice
    @sum = 0
    self.income_items.each do |item|
      @sum += item.supply_order_item.supply_order.exchange_value * (item.quantity * item.price)
    end
    @sum
  end

end
