class TechnicalSpecification < ApplicationRecord

  has_many :technical_spec_items
  accepts_nested_attributes_for :technical_spec_items, allow_destroy: true

  validates :specification_gr, presence: true, length: {maximum: 255}

  scope :order_specification_gr, ->() {
    order(:specification_gr)
  }

  scope :search, ->(name) {
    items = order_specification_gr
    items = items.where('specification_gr LIKE :value', value: "%#{name}%") if name.present?
    items
  }
end
