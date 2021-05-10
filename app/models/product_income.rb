class ProductIncome < ApplicationRecord
  belongs_to :user
  belongs_to :logistic
  has_many :product_income_items, dependent: :destroy
  has_many :product_income_products, dependent: :destroy
  has_many :shipping_ub_samples, through: :product_income_products

  accepts_nested_attributes_for :product_income_items, allow_destroy: true
  accepts_nested_attributes_for :product_income_products, allow_destroy: true

  validates :cargo_price, :logistic_id, :income_date, presence: true
  validates :product_income_products, :length => {:minimum => 1}
  after_save :set_sample_per_cost

  attr_accessor :number

  scope :income_date_desc, -> {
    order(income_date: :desc)
  }

  scope :search, ->(code, start, finish) {
    items = income_date_desc
    items = items.where('id LIKE :value', value: "%#{code}%") if code.present?
    items = items.where('? <= income_date AND income_date <= ?', start.to_time, finish.to_time + 1.days) if start.present? && finish.present?
    items
  }

  def sum_quantity
    product_income_products.sum(:quantity)
  end

  def cargo_per
    if self[:cargo_per].present?
      self[:cargo_per]
    else
      c = self.cargo_price.to_f / self.sum_quantity
      self.update_column(:cargo_per, c)
      c
    end
  end

  def sum_number_of_ub_sample
    sample_id = Hash.new
    s = 0
    shipping_ub_samples.each do |sample|
      unless sample_id[sample.id]
        s += sample.number
        sample_id[sample.id] = sample.id
      end
    end
    s
  end

  private

  def valid_quantity
    remainder = Hash.new
    sums = Hash.new

    product_income_items.each do |i|
      if i.supply_order_item.present?
        unless remainder[i.supply_order_item.id].present?
          remainder[i.supply_order_item.id] = ProductIncomeBalance.balance(i.supply_order_item.product_id)
          sums[i.supply_order_item.id] = 0
        end
        sums[i.supply_order_item.id] += (i.quantity - (i.quantity_was.presence || 0))
      end
    end

    remainder.each do |key, value|
      if value < sums[key]
        self.errors.add(:product_income_items, :over_quantity)
      end
    end
  end

  def set_sample_per_cost
    sample_ids = product_income_products.map(&:shipping_ub_sample_id).uniq
    if sample_ids.present?
      sample_ids.each do |id|
        if id.present?
          ub_sample = ShippingUbSample.find(id)
          product_ids = product_income_products.by_ub_sample_id(id).map(&:id).to_a
          q = product_income_items.quantity_income_product_ids(product_ids)
          ub_sample.update_column(:per_cost, ub_sample.cost / q)
        end
      end
    end
  end
end
