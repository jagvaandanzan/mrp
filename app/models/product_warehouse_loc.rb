class ProductWarehouseLoc < ApplicationRecord
  belongs_to :salesman_travel
  belongs_to :product
  belongs_to :location, :class_name => "ProductLocation"
  belongs_to :feature_item, :class_name => "ProductFeatureItem"
  belongs_to :feature_rel, :class_name => "ProductFeatureRel"

  scope :by_travel, ->(travel_id) {
    select("products.name as name,
            product_locations.name as deck,
            product_warehouse_locs.*")
        .joins(:product)
        .joins(:location)
        .where(salesman_travel_id: travel_id)
        .order(:queue)
  }

  def feature
    feature_item.name
  end

  def image
    feature_rel.image_url
  end
end
