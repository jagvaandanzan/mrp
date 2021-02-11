class ProductLocationBalance < ApplicationRecord
  belongs_to :product_location
  belongs_to :product_feature_item
  belongs_to :income_item, :class_name => "ProductIncomeItem", optional: true
  belongs_to :income_location, :class_name => "ProductIncomeLocation", optional: true
  belongs_to :travel, :class_name => "SalesmanTravel", optional: true
  belongs_to :warehouse_loc, :class_name => "ProductWarehouseLoc", optional: true

  before_validation :check_location

  attr_accessor :x, :y, :z

  scope :by_location_id, ->(location_id) {
    where(product_location_id: location_id)
  }

  scope :by_feature_item_id, ->(feature_item_id) {
    where(product_feature_item_id: feature_item_id)
  }

  private

  def check_location
    if x.present? && y.present? && z.present?
      locs = ProductLocation.by_xyz(x, y, z)
      if locs.present?
        self.product_location = locs.first
      else
        self.product_location = ProductLocation.create(x: x, y: y, z: z)
      end
    end
  end

end