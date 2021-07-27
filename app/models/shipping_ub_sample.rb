class ShippingUbSample < ApplicationRecord
  belongs_to :shipping_ub
  has_many :product_income_products, class_name: "ProductIncomeProduct"
  has_many :product_income_items, through: :product_income_products
  validates :number, :cost, presence: true

  scope :received_at_nil, -> {
    where("received_at IS ?", nil)
  }

  scope :by_shipping_id, ->(ids){
    where(shipping_ub_id: ids)
  }

  scope :cost, ->(ids){
    joins(:product_income_items)
      .where("shipping_ub_id IN (?)", ids)
  }
  scope :by_calc_nil, ->(is_nil) {
    joins(:product_income_items)
      .where("product_income_items.calculated IS#{is_nil == "true" ? '' : ' NOT'} ?", nil)
  }

  scope :by_date, ->(start, finish) {
    where('? <= created_at AND created_at <= ?', start.to_time, finish.to_time + 1.days)
  }

end
