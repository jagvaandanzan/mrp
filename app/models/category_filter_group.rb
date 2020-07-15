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
  scope :search_name, ->(name) {
    where('name_en LIKE :value', value: "%#{name}%") if name.present?
  }
  scope :qe_name, ->(name) {
    where('LOWER(name_en) = ?', name) if name.present?
  }

  scope :search, ->(category_id, category_code, category_name, name) {
    items = order_name
    items = items.joins(:product_category) if category_code.present? || category_name.present?
    items = items.where('product_categories.code = ?', category_code) if category_code.present?
    items = items.where('product_categories.name LIKE :value', value: "%#{category_name}%") if category_name.present?
    items = items.where('product_category_id = ?', category_id) if category_id.present?
    items = items.where('name LIKE :value', value: "%#{name}%") if name.present?
    items
  }
end
