class ProductSupplyOrder < ApplicationRecord
  # acts_as_paranoid
  belongs_to :logistic
  belongs_to :user

  has_many :product_sample_images
  has_many :product_supply_order_items, dependent: :destroy
  has_many :products, through: :product_supply_order_items
  has_many :supply_features, through: :product_supply_order_items

  accepts_nested_attributes_for :product_supply_order_items, allow_destroy: true
  accepts_nested_attributes_for :product_sample_images, allow_destroy: true

  enum order_type: {is_basic: 0, is_sample: 1}
  enum status: {draft: 0, order_created: 1, ordered: 2, cost_included: 3, warehouse_received: 4, calculated: 5, clarification: 6, clarified: 7, canceled: 8}
  enum exchange: {cny: 0, usd: 1, eur: 2, rub: 3, jpy: 4, gbr: 5, mnt: 6}

  attr_accessor :tab_index, :product_name, :option_rels

  after_create :set_default
  validates :logistic_id, :exchange, presence: true

  with_options :if => Proc.new {|m| m.is_sample? && m.tab_index.to_i == 0} do
    validates :product_name, presence: true, length: {maximum: 255}
    validates :link, presence: true
    before_save :set_product
  end

  scope :created_at_desc, -> {
    order(created_at: :desc)
  }

  scope :search, ->(start, finish, supply_code, product_name, order_type) {
    items = order("product_supply_orders.ordered_date": :desc)
    items = items.where('product_supply_orders.code LIKE :value', value: "%#{supply_code}%") if supply_code.present?
    items = items.where('ordered_date >= :s AND ordered_date <= :f', s: "#{start}", f: "#{finish}") if start.present? && finish.present?
    items = items.joins(:products).where('products.code LIKE :value', value: "%#{product_name}%") if product_name.present?
    items = items.where(order_type: order_type) if order_type.present?
    items
  }

  scope :by_sum_price_nil, ->() {
    where("sum_price IS ?", nil)
  }

  def exchange_value
    ApplicationController.helpers.get_f(self[:exchange_value])
  end

  def get_currency(value)
    ApplicationController.helpers.get_currency(value, Const::CURRENCY[exchange_before_type_cast.to_i], 2)
  end

  def code_with_info
    "Захиалга - #{self.code}"
  end

  def get_status
    "#{ordered_date.strftime('%F')} - #{status_i18n} - #{user.name}"
  end

  def update_status(stat)
    # Бүгд дор хаяж тэнцүү болсон үед солино
    exist_items = product_supply_order_items.by_status_lower(stat)
    unless exist_items.present?
      self.update_column(:status, stat)
    end
  end

  def get_product
    if self.product_supply_order_items.present?
      product_supply_order_item = self.product_supply_order_items.first
      product_supply_order_item.product
    end
  end

  def set_sum_price
    sum = 0
    product_supply_order_items.each do |order_item|
      sum += order_item.sum_price
    end

    self.update_column(:sum_price, sum.to_f.round(1))
  end

  def set_status(status)
    self.update_column(:status, status) if status > ProductSupplyOrder.statuses[self.status]
  end

  private

  def set_product
    if product_supply_order_items.present?
      product = get_product
      product.option_rels = option_rels
      product.n_name = product_name
      product.save
    else
      product = Product.new(draft: true,
                            user: user,
                            p_type: 0,
                            n_name: product_name,
                            brand_id: 69,
                            code: ApplicationController.helpers.get_code(Product.last),
                            option_rels: option_rels)

      self.product_supply_order_items << ProductSupplyOrderItem.new(product: product)
    end
  end

  def set_default
    self.update_column(:code, ApplicationController.helpers.show_id(id))
    if self.is_basic?
      product = get_product
      product.update_column(:p_type, 1) if !product.p_type.present? || product.type_sample?
    end
  end
end
