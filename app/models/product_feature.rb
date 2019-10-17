class ProductFeature < ApplicationRecord
  acts_as_paranoid

  has_many :options, :class_name => "ProductFeatureOption", :foreign_key => "product_feature_id", dependent: :destroy

  validates :name, presence: true

  scope :order_by_name, -> {
    order(:name)
  }

  scope :search, ->(sname) {
    items = order_by_name
    items = items.where('name LIKE :value', value: "%#{sname}%") if sname.present?
    items
  }
end
