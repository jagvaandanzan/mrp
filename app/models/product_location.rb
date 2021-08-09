class ProductLocation < ApplicationRecord
  acts_as_paranoid

  has_many :income_locations, :class_name => "ProductIncomeLocation", :foreign_key => "location_id"
  has_many :product_location_balances

  scope :by_xyz, ->(x, y, z) {
    where(x: x)
        .where(y: y)
        .where(z: z)
  }

  scope :get_quantity, ->(feature_item_id) {
    select("product_locations.*, SUM(product_location_balances.quantity) as quantity")
        .joins(:product_location_balances)
        .where("product_location_balances.product_feature_item_id = ?", feature_item_id)
        .where("quantity > ?", 0)
        .group(:id)
        .order(:x)
        .order(:y)
        .order(:z)
  }

  def name
    "X#{x}Y#{y}Z#{z}"
  end

end
