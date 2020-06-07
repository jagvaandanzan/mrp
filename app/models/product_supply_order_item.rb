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


  def get_currency(value)
    ApplicationController.helpers.get_currency(value, Const::CURRENCY[get_model.exchange_before_type_cast.to_i], 0)
  end

  scope :search_by_sample, ->(start, finish, supply_code, product_name) {
    items = joins(:product_sample)
    items = items.where('? <= product_samples.ordered_date AND product_samples.ordered_date <= ?', start.to_time, finish.to_time + 1.days) if start.present? && finish.present?
    items = items.where('product_samples.code LIKE :value', value: "%#{supply_code}%") if supply_code.present?
    items = items.joins(:product).where('products.code LIKE :value OR products.name LIKE :value', value: "%#{product_name}%") if product_name.present?
    items.order("product_samples.ordered_date": :desc)
    items
  }

  scope :search_by_order, ->(start, finish, supply_code, product_name) {
    items = joins(:product_supply_order)
    items = items.where('? <= product_supply_orders.ordered_date AND product_supply_orders.ordered_date <= ?', start.to_time, finish.to_time + 1.days) if start.present? && finish.present?
    items = items.where('product_supply_orders.code LIKE :value', value: "%#{supply_code}%") if supply_code.present?
    items = items.joins(:product).where('products.code LIKE :value OR products.name LIKE :value', value: "%#{product_name}%") if product_name.present?
    items.order("product_supply_orders.ordered_date": :desc)
    items
  }

  scope :created_at_desc, -> {
    order(created_at: :desc)
  }

  scope :search, ->(start, finish, supply_code, product_name) {
    items = left_joins(:product_sample)
                .left_joins(:product_supply_order)
    if start.present? && finish.present?
      items = items.where('product_samples.id IS ? AND ? <= product_supply_orders.ordered_date AND product_supply_orders.ordered_date <= ?', nil, start.to_time, finish.to_time + 1.days)
                  .or(where('product_supply_orders.id IS ? AND ? <= product_samples.ordered_date AND product_samples.ordered_date <= ?', nil, start.to_time, finish.to_time + 1.days))
    end
    if supply_code.present?
      items = items.where('product_samples.id IS ? AND product_supply_orders.code LIKE :value', nil, value: "%#{supply_code}%")
                  .or(where('product_supply_orders.id IS ? AND product_samples.code LIKE :value',nil, value: "%#{supply_code}%"))

    end
    items = items.joins(:product).where('products.code LIKE :value OR products.name LIKE :value', value: "%#{product_name}%") if product_name.present?
    items.created_at_desc
  }

  def product_name_with_code
    "#{self.product.code} - #{self.product.name}"
  end

  def set_sum_price
    sum = 0
    supply_features.each do |feature|
      sum += feature.quantity * feature.price
    end

    self.update_attributes(sum_price: sum.to_f.round(1), sum_tug: (sum * get_model.exchange_value).to_f.round(1))
  end

  private

  def get_model
    if product_supply_order.present?
      product_supply_order
    else
      product_sample
    end
  end

end
