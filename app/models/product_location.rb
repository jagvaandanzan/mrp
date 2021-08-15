class ProductLocation < ApplicationRecord
  acts_as_paranoid

  has_many :income_locations, :class_name => "ProductIncomeLocation", :foreign_key => "location_id"
  has_many :product_location_balances

  scope :by_xyz, ->(x, y, z) {
    where(x: x)
        .where(y: y)
        .where(z: z)
  }
  scope :order_xyz, ->() {
    order(:x)
        .order(:y)
        .order(:z)
  }
  scope :get_quantity, ->(feature_item_id) {
    if feature_item_id.nil?
      []
    else
      select("product_locations.*, SUM(product_location_balances.quantity) as quantity")
          .joins(:product_location_balances)
          .where("product_location_balances.product_feature_item_id = ?", feature_item_id)
          .group(:id)
          .order(:x)
          .order(:y)
          .order(:z)
    end
  }

  def name
    "X#{x}Y#{y}Z#{z}"
  end

end
