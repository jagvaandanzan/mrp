class ProductWarehouseLoc < ApplicationRecord
  belongs_to :salesman_travel
  belongs_to :product
  belongs_to :location, :class_name => "ProductLocation"
  belongs_to :feature_item, :class_name => "ProductFeatureItem"
  belongs_to :feature_rel, :class_name => "ProductFeatureRel"

  scope :by_travel, ->(travel_id, id) {
    items = select("products.name as name,
            products.main_code as code,
            product_locations.name as deck,
            product_warehouse_locs.*")
                .joins(:product)
                .joins(:location)
    items = items.where(salesman_travel_id: travel_id) if travel_id.present?
    items = items.where(id: id) if id.present?

    items.order(:queue)
  }

  def feature
    feature_item.name
  end

  def image
    feature_rel.image_url
  end

  def barcode
    "123456789"
  end
end
