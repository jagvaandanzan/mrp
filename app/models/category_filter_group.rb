class CategoryFilterGroup < ApplicationRecord
  acts_as_paranoid
  belongs_to :product_category, optional: true
  has_many :category_filters

  accepts_nested_attributes_for :category_filters, allow_destroy: true

  validates :name, presence: true
  validates_uniqueness_of :name, scope: [:product_category_id]

  scope :order_name, ->() {
    order(:name)
  }
  scope :search, ->(name) {
    items = order_name
    items = items.where('name LIKE :value', value: "%#{name}%") if name.present?
    items
  }
end
