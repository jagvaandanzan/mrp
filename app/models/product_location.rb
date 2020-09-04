class ProductLocation < ApplicationRecord
  acts_as_paranoid

  has_many :children, :class_name => "ProductLocation", :foreign_key => "parent_id"
  has_many :income_items, :class_name => "ProductIncomeItem", :foreign_key => "location_id"
  has_many :income_locations, :class_name => "ProductIncomeLocation", :foreign_key => "location_id"
  has_many :product_location_balances

  scope :by_xyz, ->(x, y, z) {
    where(x: x)
        .where(y: y)
        .where(z: z)
  }

  scope :get_quantity, ->(feature_item_id) {
    select("product_locations.id, SUM(product_location_balances.quantity) as quantity")
        .joins(:product_location_balances)
        .where("product_location_balances.feature_item_id = ?", feature_item_id)
        .where("quantity > ?", 0)
        .group(:id)
        .order(:x)
        .order(:y)
        .order(:z)
  }

  def name
    "x#{x} y#{y} z#{z}"
  end

end
