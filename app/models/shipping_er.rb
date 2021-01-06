class ShippingEr < ApplicationRecord
  belongs_to :logistic

  has_many :shipping_er_products, dependent: :destroy
  has_many :product_supply_features, through: :shipping_er_products
  has_many :products, through: :shipping_er_products

  accepts_nested_attributes_for :shipping_er_products, allow_destroy: true

  enum s_type: {post_cargo: 0, post_er: 1, cargo_er: 2, cargo_post: 3}

  before_save :set_per_price
  attr_accessor :number

  validates :date, :cost, :s_type, presence: true
  validate :product_should_be_uniq

  scope :order_created_at, -> {
    order(:date)
  }

  scope :search, ->(start, finish, product_name) {
    items = order_created_at
    items = items.joins(:products)
                .where('products.code LIKE :value OR products.n_name LIKE :value', value: "%#{product_name}%").group("id") if product_name.present?
    items = items.where('? <= date AND date <= ?', start.to_time, finish.to_time + 1.days) if start.present? && finish.present?
    items
  }

  def product_names
    names = ""
    products.each_with_index {|product, index|
      if index > 0
        names += ", "
      end
      names += product.full_name
    }
    names
  end

  def sum_quantity
    shipping_er_products.sum(:quantity)
  end

  private

  def product_should_be_uniq
    uniq_by_product_id = shipping_er_products.uniq(&:product_id)

    if shipping_er_products.length != uniq_by_product_id.length
      self.errors.add(:shipping_er_products, :taken)
    end
  end

  def set_per_price
    self.per_price = cost / sum_quantity
  end

end
