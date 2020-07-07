class ShippingUb < ApplicationRecord
  belongs_to :logistic

  has_many :shipping_ub_items, dependent: :destroy
  has_many :products, through: :shipping_ub_items

  accepts_nested_attributes_for :shipping_ub_items, allow_destroy: true

  validates :date, presence: true
  validates :shipping_ub_items, :length => {:minimum => 1}

  scope :order_created_at, -> {
    order(:date)
  }

  scope :search, ->(start, finish, product_name) {
    items = order_created_at
    items = items.joins(:products)
                .where('products.code LIKE :value OR products.name LIKE :value', value: "%#{product_name}%").group("id") if product_name.present?
    items = items.where('? <= date AND date <= ?', start.to_time, finish.to_time + 1.days) if start.present? && finish.present?
    items
  }

  def shipping_ub_item_count
    shipping_ub_items
        .sum(:loaded)
  end
end
