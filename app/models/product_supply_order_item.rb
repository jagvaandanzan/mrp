class ProductSupplyOrderItem < ApplicationRecord
  belongs_to :product_supply_order, optional: true
  belongs_to :product_sample, optional: true
  belongs_to :product, -> {with_deleted}
  has_many :income_items, :class_name => "ProductIncomeItem", :foreign_key => "supply_order_item_id", dependent: :destroy
  has_many :supply_features, :class_name => "ProductSupplyFeature", :foreign_key => "order_item_id", dependent: :destroy
  accepts_nested_attributes_for :supply_features, allow_destroy: true

  has_attached_file :image, :path => ":rails_root/public/product_supply_order_items/image/:id_partition/:style.:extension", styles: {original: "1200x1200>", tumb: "400x400>"}, :url => '/product_supply_order_items/image/:id_partition/:style.:extension'
  validates_attachment :image,
                       content_type: {content_type: ["image/jpeg", "image/x-png", "image/png"], message: :content_type}, size: {less_than: 4.megabytes}
  attr_accessor :tab_index

  validates :product_id, presence: true

  with_options :if => Proc.new {|m| m.product_sample.present?} do
    validates :link, presence: true
  end

  scope :search, ->(start, finish, supply_code, product_name) {
    items = joins(:product_supply_order)
    items = items.where('? <= product_supply_orders.ordered_date AND product_supply_orders.ordered_date <= ?', start.to_time, finish.to_time + 1.days) if start.present? && finish.present?
    items = items.where('product_supply_orders.code LIKE :value', value: "%#{supply_code}%") if supply_code.present?
    items = items.joins(:product).where('products.code LIKE :value OR products.name LIKE :value', value: "%#{product_name}%") if product_name.present?
    items.order("product_supply_orders.ordered_date": :desc)
    items
  }

  def product_name_with_code
    "#{self.product.code} - #{self.product.name}"
  end

end
