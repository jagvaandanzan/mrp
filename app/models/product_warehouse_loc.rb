class ProductWarehouseLoc < ApplicationRecord
  belongs_to :salesman_travel
  belongs_to :product
  belongs_to :location, :class_name => "ProductLocation"
  belongs_to :feature_item, :class_name => "ProductFeatureItem"

  scope :by_travel, ->(travel_id, id = nil) {
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

  scope :by_load_at, ->(load) {
    where("load_at is#{load ? ' NOT' : ''} ?", nil)
  }


  def feature
    feature_item.name
  end

  def image
    feature_item.img
  end

  def barcode
    "123456789"
  end
end
