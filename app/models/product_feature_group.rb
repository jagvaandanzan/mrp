class ProductFeatureGroup < ApplicationRecord
  acts_as_paranoid

  has_many :product_feature_options, :class_name => "ProductFeatureOption", :foreign_key => "group_id", dependent: :destroy

  validates :queue, :name, :code, presence: true

  scope :order_name, -> {
    order(:queue)
        .order(:name)
  }

  scope :search, ->(sname) {
    items = order_name
    items = items.where('name LIKE :value', value: "%#{sname}%") if sname.present?
    items
  }

end
