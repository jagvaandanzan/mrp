class TechnicalSpecification < ApplicationRecord

  validates :specification, presence: true, length: {maximum: 255}

  scope :order_specification, ->() {
    order(:specification)
  }

  scope :search, ->(search_specification) {
    items = order_specification
    items = items.where('specification LIKE :value', value: "%#{search_specification}%") if search_specification.present?
    items
  }
end
