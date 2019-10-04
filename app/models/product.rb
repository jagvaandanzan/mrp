class Product < ApplicationRecord
  acts_as_paranoid

  belongs_to :category, -> { with_deleted }, :class_name => "ProductCategory", optional: true
  has_many :product_feature_rels, :class_name => "ProductFeatureRel", :foreign_key => "product_id"
  has_many :supply_order_items, :class_name => "ProductSupplyOrderItem", :foreign_key => "product_id"
  has_many :product_sale_items, :class_name => "ProductSaleItem", :foreign_key => "product_id"

  validates :name, :code, :sale_price, :discount_price, presence: true

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

  def name_with_code
    "#{self.code} - #{self.name}"
  end

end
