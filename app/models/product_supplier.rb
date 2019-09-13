class ProductSupplier < ApplicationRecord
  has_many :supply_orders, :class_name => "ProductSupplyOrder", :foreign_key => "supplier_id"

  validates :name, presence: true

  scope :order_by_name, -> {
    order(:name)
  }

  scope :search, ->(sname) {
    items = order_by_name
    items = items.where('name LIKE :value OR code LIKE :value', value: "%#{sname}%") if sname.present?
    items
  }
end
