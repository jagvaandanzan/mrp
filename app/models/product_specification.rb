class ProductSpecification < ApplicationRecord
  belongs_to :product
  belongs_to :spec_item, :class_name => "TechnicalSpecItem"

  validates_uniqueness_of :spec_item_id, scope: [:product_id]

  validates :specification, presence: true, length: {maximum: 255}
  validates :spec_item_id, presence: true

  scope :by_spec_item_id, ->(spec_item_id) {
    where(spec_item_id: spec_item_id)
  }


end
