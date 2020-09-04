class ProductLocationBalance < ApplicationRecord
  belongs_to :product_location
  belongs_to :feature_item, :class_name => "ProductFeatureItem"
  belongs_to :income_item, :class_name => "ProductIncomeItem", optional: true
  belongs_to :income_location, :class_name => "ProductIncomeLocation", optional: true
  belongs_to :travel, :class_name => "SalesmanTravel", optional: true
  belongs_to :warehouse_loc, :class_name => "ProductWarehouseLoc", optional: true
end