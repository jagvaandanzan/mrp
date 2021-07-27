class ProductSupplyFeature < ApplicationRecord
  belongs_to :order_item, :class_name => "ProductSupplyOrderItem"
  belongs_to :feature_item, :class_name => "ProductFeatureItem"
  belongs_to :product
  has_one :product_supply_order, through: :order_item
  has_one :product_income_balance, :class_name => "ProductIncomeBalance", :foreign_key => "supply_feature_id", dependent: :destroy
  has_many :product_income_items, class_name: "ProductIncomeItem", foreign_key: "supply_feature_id", dependent: :destroy
  has_many :product_income_products, through: :product_income_items
  has_many :product_income, through: :product_income_items
  has_many :shipping_er_features, class_name: "ShippingErFeature", foreign_key: "supply_feature_id", dependent: :destroy
  has_many :shipping_ub_features, class_name: "ShippingUbFeature", foreign_key: "supply_feature_id", dependent: :destroy
  has_many :shipping_er_product, through: :shipping_er_features
  has_many :shipping_ub_product, through: :shipping_ub_features
  has_many :shipping_ers, through: :shipping_er_product
  has_many :shipping_ub, through: :shipping_ub_product
  before_save :set_cn_name
  attr_accessor :is_create, :is_update, :remainder, :cn_name

  paginates_per 100

  enum order_type: {is_basic: 0, is_sample: 1}

  with_options :if => Proc.new {|m| m.is_create.present?} do
    validates :quantity, :price, presence: true
    validates_numericality_of :quantity, greater_than: 0
    before_save :set_product_balance
    before_save :set_sum_price
  end

  with_options :if => Proc.new {|m| m.is_update.present?} do
    validates :quantity_lo, :price_lo, presence: true
  end

  with_options :unless => Proc.new {|m| m.is_create.present?} do
    before_update :set_sum_price_lo
  end

  scope :find_to_er, ->(order_type, product_id = nil, by_code, by_product_name) {
    items = left_joins(:shipping_er_features)
                .left_joins(:order_item)
    items = items.left_joins(:product_supply_order) unless order_type.nil?
    items = items.group("product_supply_features.id")
                .having("product_supply_features.quantity_lo IS NOT NULL AND product_supply_features.quantity_lo > 0")
                .having("SUM(shipping_er_features.quantity) IS NULL OR SUM(shipping_er_features.quantity) < product_supply_features.quantity_lo") # хэд хэд тасалж авсан тохиолдлыг шалгаж байна
                .select("product_supply_features.*, #{order_type.nil? ? '' : 'product_supply_orders.code as order_code, '}product_supply_features.quantity_lo - IFNULL(SUM(shipping_er_features.quantity), 0) as remainder")
    items = items.where(product_id: product_id) unless product_id.nil?
    items = items.where("product_supply_orders.order_type = ?", order_type) unless order_type.nil?
    items = items.where('product_supply_orders.code LIKE :value', value: "%#{by_code}%") if by_code.present?
    items = items.left_joins(:product).where('products.code LIKE :value OR products.n_name LIKE :value', value: "%#{by_product_name}%") if by_product_name.present?
    items = items.where("product_supply_order_items.status < ?", 8)
    items
  }

  scope :find_to_income, ->(order_type, product_id = nil, by_code, by_product_name) {
    items = left_joins(:product_income_items)
                .left_joins(:order_item)
    items = items.left_joins(:product_supply_order) unless order_type.nil?
    items = items.group("product_supply_features.id")
                .having("product_supply_features.quantity_lo IS NOT NULL")
                .having("SUM(product_income_items.quantity) IS NULL OR SUM(product_income_items.quantity) < product_supply_features.quantity_lo") # хэд хэд тасалж авсан тохиолдлыг шалгаж байна
                .select("product_supply_features.*, #{order_type.nil? ? '' : 'product_supply_orders.code as order_code, '}product_supply_features.quantity_lo - IFNULL(SUM(product_income_items.quantity), 0) as remainder")
    items = items.where(product_id: product_id) unless product_id.nil?
    items = items.where("product_supply_orders.order_type = ?", order_type) unless order_type.nil?
    items = items.where('product_supply_orders.code LIKE :value', value: "%#{by_code}%") if by_code.present?
    items = items.left_joins(:product).where('products.code LIKE :value OR products.n_name LIKE :value', value: "%#{by_product_name}%") if by_product_name.present?
    items = items.where("product_supply_order_items.status < ?", 8)
    items
  }


  scope :purchased_er, ->{
    items = joins(:product_supply_order)
                 .where("product_supply_orders.status = 2")
    items = items.left_joins(:shipping_er_features)
              .where("shipping_er_features.supply_feature_id IS NULL")
    items = items.left_joins(:product_income_items)
              .where("product_income_items.supply_feature_id IS NULL")
    items = items.joins(:order_item)
                 .where("product_supply_features.quantity_lo IS NOT NULL AND product_supply_features.price_lo IS NOT NULL AND product_supply_features.sum_price_lo IS NOT NULL AND product_supply_features.note_lo IS NOT NULL")
    items
  }

  scope :received_er, ->{
    items = joins(:shipping_er_features)
    items = items.left_joins(:shipping_ub_features)
                 .where("shipping_ub_features.supply_feature_id IS NULL")
    items = items.joins(:shipping_er_product)
    items = items.left_joins(:product_income_items)
                 .where("product_income_items.supply_feature_id IS NULL")
    items = items.joins(:order_item)
              .where("product_supply_features.quantity_lo IS NOT NULL AND product_supply_features.price_lo IS NOT NULL AND product_supply_features.sum_price_lo IS NOT NULL AND product_supply_features.note_lo IS NOT NULL")
    items = items.joins(:product_supply_order)
              .where("product_supply_orders.status = 2")
    items
  }

  scope :ship_ub, ->{
    items = joins(:shipping_er_features)
    items = items.joins(:shipping_er_product)
    items = items.joins(:shipping_ub_features)
    items = items.joins(:shipping_ub_product)
    items = items.left_joins(:product_income_items)
                 .where("product_income_items.supply_feature_id IS NULL")
    items = items.joins(:order_item)
              .where("product_supply_features.quantity_lo IS NOT NULL AND product_supply_features.price_lo IS NOT NULL AND product_supply_features.sum_price_lo IS NOT NULL AND product_supply_features.note_lo IS NOT NULL")
    items = items.joins(:product_supply_order)
              .where("product_supply_orders.status = 2")
    items
  }

  scope :in_ub, ->{
    items = joins(:product_income_items)
    items = items.joins(:product_income_products)
    items = items.joins(:shipping_er_features)
    items = items.joins(:shipping_er_product)
    items = items.joins(:shipping_ub_features)
    items = items.joins(:shipping_ub_product)
    items = items.joins(:order_item)
                 .where("product_supply_features.quantity_lo IS NOT NULL AND product_supply_features.price_lo IS NOT NULL AND product_supply_features.sum_price_lo IS NOT NULL AND product_supply_features.note_lo IS NOT NULL")
    items = items.joins(:product_supply_order)
                 .where("product_supply_orders.status = 2")
    items
  }

  scope :shipping_ub, ->{
    joins(:shipping_ub)
      .pluck("shipping_ubs.id")
  }

  scope :by_calc_nil, ->(is_nil) {
    joins(:order_item)
      .where("product_income_items.calculated IS#{is_nil == "true" ? '' : ' NOT'} ?", nil)
  }

  scope :by_clarify, ->(clarify) {
    joins(:order_item)
      .where("product_income_items.clarify = ?", clarify)
  }

  scope :not_in_er_cost, ->{
    cost = left_joins(:shipping_er_features)
      .where("shipping_er_features.supply_feature_id IS NULL")
    cost = cost.left_joins(:product_income_items)
                 .where("product_income_items.supply_feature_id IS NULL")
    cost = cost.joins(:order_item)
               .group("product_supply_features.order_item_id")
                .pluck("product_supply_order_items.cost")
                .sum(&:to_f)
    cost
  }


  scope :by_income_date, ->(start, finish) {
    joins(:product_income_items)
      .where('? <= product_supply_features.updated_at AND product_supply_features.updated_at <= ?', start.to_time, finish.to_time + 1.days)
  }

  scope :by_feature_item_id, ->(feature_item_id) {
    where(feature_item_id: feature_item_id)
  }

  scope :by_order_item, ->(order_item_id) {
    where('product_supply_features.order_item_id IN (?)', order_item_id)
  }

  scope :by_feature_id, ->(feature_ids) {
    where("product_supply_features.id IN (?)", feature_ids)
  }

  scope :by_feature, ->(feature_ids) {
    joins(:order_item)
      .where("product_supply_features.id IN (?)", feature_ids)
  }

  scope :by_product_id, ->(product_id) {
    where(product_id: product_id)
  }

  scope :by_feature_item_ids, ->(feature_item_ids) {
    where("feature_item_id IN (?)", feature_item_ids)
  }

  scope :by_order_item_id, ->(order_item_id) {
    where(order_item_id: order_item_id)
  }

  scope :by_date, ->(start, finish) {
    where('? <= product_supply_features.updated_at AND product_supply_features.updated_at <= ?', start.to_time, finish.to_time + 1.days)
  }

  scope :sum_price_lo, ->() {
    pluck("price_lo * quantity_lo")
        .sum(&:to_f)
  }

  scope :sum_cost_lo, ->() {
    pluck(:cost)
      .sum(&:to_f)
  }

  scope :quantity, ->(id){
    where(order_item_id:  id).pluck(:quantity_lo).sum
  }

  def price
    ApplicationController.helpers.get_f(self[:price])
  end

  def price_lo
    ApplicationController.helpers.get_f(self[:price_lo])
  end

  def code
    get_model.code
  end

  def get_currency(value)
    ApplicationController.helpers.get_currency(value, Const::CURRENCY[get_model.exchange_before_type_cast.to_i], 2)
  end

  private

  def get_model
    order_item.product_supply_order
  end

  def get_user
    order_item.product_supply_order.user
  end

  def set_sum_price
    self.sum_price = (price * quantity).to_f.round(2)
  end

  def set_sum_price_lo
    self.sum_price_lo = (price_lo * quantity_lo).to_f.round(2) if price_lo.present? && quantity_lo.present?
  end

  def set_product_balance
    if product_income_balance.present?
      self.product_income_balance.update(
          quantity: quantity
      )
    else
      self.product_income_balance = ProductIncomeBalance.create(product: order_item.product,
                                                                feature_item: feature_item,
                                                                user_supply: get_user,
                                                                quantity: quantity)
    end
  end

  def set_cn_name
    feature_item.update_column(:c_name, cn_name) if cn_name.present? && feature_item.name != cn_name
  end
end
