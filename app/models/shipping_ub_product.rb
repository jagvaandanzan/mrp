class ShippingUbProduct < ApplicationRecord
  belongs_to :shipping_ub, optional: true
  belongs_to :shipping_ub_box
  belongs_to :product
  belongs_to :shipping_er_product
  has_many :product_income_products

  has_many :shipping_ub_features, dependent: :destroy
  before_save :set_shipping_ub, :set_per_price

  attr_accessor :remainder

  validates :quantity, :cargo, :cost, presence: true
  with_options :if => Proc.new {|m| m.remainder.present?} do
    validates_numericality_of :quantity, less_than_or_equal_to: Proc.new(&:remainder)
  end
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

  scope :sum_quantity_by_er_product, ->(er_product_id) {
    where(shipping_er_product_id: er_product_id)
        .sum(:quantity)
  }

  def set_shipping_ub
    self.shipping_ub_id = shipping_ub_box.shipping_ub_id
    was_ids = self.shipping_ub_features.map(&:shipping_er_feature_id).to_a
    new_ids = shipping_er_product.shipping_er_features.find_to_ub(was_ids).map(&:id).to_a
    self.shipping_ub_features.by_ids(was_ids - new_ids).destroy_all

    q_sum = 0
    shipping_er_product.shipping_er_features.find_to_ub(was_ids).each do |f|
      is_break = false
      rem = f[:remainder]
      shipping_ub_feature = nil
      if was_ids.include?(f.id)
        shipping_ub_features = self.shipping_ub_features
                                   .by_shipping_er_feature(f.id)
        shipping_ub_feature = shipping_ub_features.first
        rem += shipping_ub_feature.quantity
      end
      q = if q_sum + rem <= self.quantity
            q_sum += rem
            rem
          else
            is_break = true
            self.quantity - q_sum
          end
      if was_ids.include?(f.id)
        shipping_ub_feature.update_column(:quantity, q) unless shipping_ub_feature.nil?
      else
        self.shipping_ub_features << ShippingUbFeature.new(shipping_er_feature: f,
                                                           product: product,
                                                           supply_feature: f.supply_feature,
                                                           quantity: q)
      end
      break if is_break
    end

  end

  private

  def set_per_price
    self.per_price = cost / quantity
  end
end