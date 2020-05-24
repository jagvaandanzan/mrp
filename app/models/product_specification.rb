class ProductSpecification < ApplicationRecord
  belongs_to :product
  belongs_to :technical, :class_name => "TechnicalSpecification"

  validates_uniqueness_of :technical_id, scope: [:product_id]

  validates :specification, presence: true, length: {maximum: 255}
  validates :technical_id, presence: true

end
