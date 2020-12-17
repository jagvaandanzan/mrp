class ShippingUbProduct < ApplicationRecord
  belongs_to :shipping_ub, optional: true
  belongs_to :shipping_ub_box
  belongs_to :product
  belongs_to :shipping_er_product
  has_many :product_income_products

  has_many :shipping_ub_features, dependent: :destroy
  before_save :set_shipping_ub

  attr_accessor :remainder

  validates :quantity, :cargo, :cost, presence: true
  validates_numericality_of :quantity, less_than_or_equal_to: Proc.new(&:remainder)

  scope :by_product_id, ->(product_id) {
    where(product: product_id)
  }

  scope :find_to_incomes, ->(id = nil) {
    items = left_joins(:product_income_products)
                .group("shipping_ub_products.id")
                .having("SUM(product_income_products.quantity) IS NULL OR SUM(product_income_products.quantity) < shipping_ub_products.quantity")
                .select("shipping_ub_products.*, shipping_ub_products.quantity - IFNULL(SUM(product_income_products.quantity), 0) as remainder")
    items = items.where("shipping_ub_products.id = ?", id) unless id.nil?
    items
  }

  def set_shipping_ub
    self.shipping_ub_id = shipping_ub_box.shipping_ub_id
    self.shipping_ub_features.destroy_all
    q_sum = 0
    shipping_er_product.shipping_er_features.find_to_ub.each do |f|
      is_break = false
      q = if q_sum + f[:remainder] <= self.quantity
            q_sum += f[:remainder]
            f[:remainder]
          else
            is_break = true
            self.quantity - q_sum
          end

      self.shipping_ub_features << ShippingUbFeature.new(shipping_er_feature: f,
                                                         product: product,
                                                         supply_feature: f.supply_feature,
                                                         quantity: q)
      break if is_break
    end

  end
end