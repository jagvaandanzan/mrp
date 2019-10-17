class ProductIncomeLocation < ApplicationRecord
  belongs_to :income_item, :class_name => "ProductIncomeItem"
  belongs_to :location, :class_name => "ProductLocation"

  # validates :quantity, :location_id, presence: true
end
