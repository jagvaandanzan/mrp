class CategoryFilterGroup < ApplicationRecord
  acts_as_paranoid
  has_many :category_filters

  accepts_nested_attributes_for :category_filters, allow_destroy: true

  validates_uniqueness_of :name
  validates :name, presence: true

  scope :search, ->(name) {
    items = order(:name)
    items = items.where('name LIKE :value', value: "%#{name}%") if name.present?
    items
  }
end
