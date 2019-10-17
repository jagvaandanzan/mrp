class Product < ApplicationRecord
  acts_as_paranoid

  belongs_to :category, -> {with_deleted}, :class_name => "ProductCategory", optional: true
  has_many :product_feature_rels
  has_many :supply_order_items, :class_name => "ProductSupplyOrderItem", :foreign_key => "product_id"
  has_many :product_sale_items
  before_validation :set_defaults

  validates :name, :code, :sale_price, :discount_price, presence: true

  validates :code, uniqueness: true

  enum measure: {sh: 0, kg: 1}
  enum ptype: {zahialga: 0, deej: 1, damjuulah: 2}

  scope :order_by_name, -> {
    order(:name)
  }

  scope :search, ->(sname) {
    items = order_by_name
    items = items.where('code LIKE :value OR name LIKE :value', value: "%#{sname}%") if sname.present?
    items
  }
  scope :search_by_id, ->(id) {
    if id.present?
      where(id: id)
    else
      []
    end
  }

  def full_name
    name_with_code
  end

  def name_with_code
    "#{self.code} - #{self.name}"
  end

  private

  def set_defaults
    self.discount_price = self.sale_price if discount_price.nil?
  end

end
