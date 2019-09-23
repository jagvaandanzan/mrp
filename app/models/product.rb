class Product < ApplicationRecord
  acts_as_paranoid

  belongs_to :category, -> { with_deleted }, :class_name => "ProductCategory", optional: true
  has_many :product_feature_option_rels, :class_name => "ProductFeatureOptionRel", :foreign_key => "product_id", dependent: :destroy
  has_many :supply_order_items, :class_name => "ProductSupplyOrderItem", :foreign_key => "product_id"

  validates :name, :code, presence: true

  validates :code, uniqueness: true

  enum measure: {sh: 0, kg: 1}
  enum ptype: {zahialga: 0, deej: 1, damjuulah: 2}

  scope :order_by_name, -> {
    order(:name)
  }

  scope :search, ->(sname) {
    items = order_by_name
    items = items.where('name LIKE :value', value: "%#{sname}%") if sname.present?
    items
  }

end
