class ShippingEr < ApplicationRecord
  belongs_to :logistic

  has_many :shipping_er_products, dependent: :destroy
  has_many :product_supply_features, through: :shipping_er_products
  has_many :products, through: :shipping_er_products

  accepts_nested_attributes_for :shipping_er_products, allow_destroy: true

  enum s_type: {post_cargo: 0, post_er: 1, cargo_er: 2}

  before_save :set_per_price
  attr_accessor :number

  validates :date, :s_type, :shipping_er_products, presence: true
  validate :product_should_be_uniq

  scope :order_created_at, -> {
    order(:date)
  }

  scope :by_date, ->(start, finish) {
    where('? <= updated_at AND updated_at <= ?', start.to_time, finish.to_time + 1.days)
  }



  scope :search, ->(start, finish, product_name, order_type) {
    items = order_created_at
    items = items.joins(:products)
                .where('products.code LIKE :value OR products.n_name LIKE :value', value: "%#{product_name}%").group("id") if product_name.present?
    items = items.where('? <= date AND date <= ?', start.to_time, finish.to_time + 1.days) if start.present? && finish.present?
    items.where(order_type: order_type)
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

  def sum_cargo
    shipping_er_products.sum(:cargo)
  end

  private

  def product_should_be_uniq
    uniq_by_product_id = shipping_er_products.uniq(&:product_id)

    if shipping_er_products.length != uniq_by_product_id.length
      self.errors.add(:shipping_er_products, :taken)
    end
  end

  def set_per_price
    q = 0
    co = 0
    shipping_er_products.each do |er_p|
      q += er_p.quantity
      co += er_p.cost
    end
    self.cost = co
    self.per_price = co / q
  end

end
