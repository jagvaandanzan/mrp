class ProductIncomeItem < ApplicationRecord
  belongs_to :product_income
  belongs_to :product_income_product
  belongs_to :shipping_ub_feature, optional: true
  belongs_to :supply_feature, :class_name => "ProductSupplyFeature"
  belongs_to :product
  belongs_to :feature_item, :class_name => "ProductFeatureItem"
  has_many :income_locations, :class_name => "ProductIncomeLocation", :foreign_key => "income_item_id", dependent: :destroy
  has_many :product_income_logs, class_name: "ProductIncomeLog", foreign_key: "product_income_item_id", dependent: :destroy
  has_one :shipping_ub_product, through: :product_income_product
  has_one :shipping_er_product, through: :shipping_ub_product
  has_one :shipping_ub_sample, through: :product_income_product

  has_one :product_income_balance, :class_name => "ProductIncomeBalance", :foreign_key => "income_item_id", dependent: :destroy
  has_one :product_balance, :class_name => "ProductBalance", :foreign_key => "income_item_id", dependent: :destroy
  has_one :logistic_balance, dependent: :destroy

  accepts_nested_attributes_for :income_locations, allow_destroy: true

  before_save :set_product_balance
  before_create :set_is_match
  before_update :check_match_feature
  before_validation :set_default
  # before_validation :set_remainder

  validates :quantity, presence: true
  validates :quantity, numericality: {greater_than: 0}
  # with_options :if => Proc.new {|m| m.remainder.present?} do
  #   validates_numericality_of :quantity, less_than_or_equal_to: Proc.new(&:remainder)
  # end
  # validate :income_locations_count_check, on: :update
  attr_accessor :is_income_order, :remainder

  scope :in_ub, ->(start, finish){
    joins(:supply_feature)
      .where('? <= product_supply_features.updated_at AND product_supply_features.updated_at <= ?', start.to_time, finish.to_time + 1.days)
  }

  scope :search, ->(start, finish, income_code, supply_code, product_name) {
    items = income_date_desc
    items = items.joins(:product_income) if income_code.present? || (start.present? && finish.present?)
    items = items.where('? <= product_incomes.income_date AND product_incomes.income_date <= ?', start.to_time, finish.to_time + 1.days) if start.present? && finish.present?
    items = items.where('product_incomes.code LIKE :value', value: "%#{income_code}%") if income_code.present?
    items = items.left_joins(:supply_feature)
                .joins("LEFT JOIN product_supply_order_items ON product_supply_features.order_item_id=product_supply_order_items.id")
                .joins("LEFT JOIN product_samples ON product_supply_order_items.product_sample_id=product_samples.id")
                .joins("LEFT JOIN product_supply_orders ON product_supply_order_items.product_supply_order_id=product_supply_orders.id")
                .where('(product_samples.id IS NULL AND product_supply_orders.code LIKE :value) OR (product_supply_orders.id IS NULL AND product_samples.code LIKE :value)', value: "%#{supply_code}%") if supply_code.present?
    items = items.joins(:product).where('products.code LIKE :value OR products.n_name LIKE :value', value: "%#{product_name}%") if product_name.present?
    items
  }

  scope :receipt, ->(code, start, finish) {
    items = joins(:product_income)
    items = items.joins(:supply_feature)
    items = items.joins(:product_income_product)
    items = items.where(calculated: nil)
    items = items.where('product_income_product.id LIKE :value', value: "%#{code}%") if code.present?
    items = items.where('? <= product_supply_features.updated_at AND product_supply_features.updated_at <= ?', start.to_time, finish.to_time + 1.days) if start.present? && finish.present?
    items
  }

  scope :income_date_desc, -> {
    order(created_at: :desc)
  }

  scope :total_ordered_supply_item, ->(supply_order_item_id) {
    where(supply_order_item_id: supply_order_item_id).sum(:quantity)
  }

  scope :sum_quantity_by_product_feature, ->(product_id, feature_ids) {
    where(product_id: product_id)
        .where("supply_feature_id IN (?)", feature_ids)
        .sum(:quantity)
  }

  scope :by_product_feature_ids, ->(product_id, feature_ids) {
    where(product_id: product_id)
        .where("supply_feature_id IN (?)", feature_ids)
  }
  scope :by_product_feature_id, ->(product_id, feature_id) {
    where(product_id: product_id)
      .where("supply_feature_id = ?", feature_id)
  }
  scope :by_shipping_ub_feature, ->(shipping_ub_feature_id) {
    where(shipping_ub_feature_id: shipping_ub_feature_id)
  }
  scope :by_ids, ->(ids) {
    where("id IN (?)", ids)
  }
  scope :not_match, ->() {
    where(is_match: false)
  }
  scope :quantity_income_product_ids, ->(income_product_ids) {
    where("product_income_product_id IN (?)", income_product_ids)
        .sum(:quantity)
  }
  scope :by_income_date, ->(start, finish) {
    joins(:product_income)
        .where('? <= product_incomes.income_date AND product_incomes.income_date <= ?', start.to_time, finish.to_time + 1.days)
  }
  scope :by_calc_nil, ->(is_nil) {
    where("product_income_items.calculated IS#{is_nil == "true" ? '' : ' NOT'} ?", nil)
  }
  scope :sum_shipping_er_cost, ->() {
    joins(:shipping_er_product)
        .sum("shipping_er_products.per_price * product_income_items.quantity")
  }
  scope :sum_shipping_er_cost, ->() {
    joins(:shipping_er_product)
        .pluck("shipping_er_products.per_price * product_income_items.quantity")
        .sum(&:to_f)
  }
  scope :sum_shipping_ub_product_cost, ->() {
    joins(:shipping_ub_product)
        .pluck("shipping_ub_products.per_price * product_income_items.quantity")
        .sum(&:to_f)
  }
  scope :sum_shipping_ub_sample_cost, ->() {
    joins(:shipping_ub_sample)
        .pluck("shipping_ub_samples.per_cost * product_income_items.quantity")
        .sum(&:to_f)
  }
  scope :sum_supply_feature_cost, ->() {
    joins(:supply_feature)
        .pluck("product_supply_features.price_lo * product_income_items.quantity")
        .sum(&:to_f)
  }

  scope :supply_feature_cost, ->() {
      pluck("product_supply_features.price_lo * product_income_items.quantity")
      .sum(&:to_f)
  }
  scope :by_clarify, ->(clarify) {
    where("product_income_items.clarify = ?", clarify)
  }

  scope :by_income_product_id, -> (income_product_id){
    where("product_income_items.product_income_product_id in (?)", income_product_id)
  }

  scope :quantity, ->(){
    sum(:quantity)
  }

  def get_balance
    ProductIncomeBalance.balance(product_id)
  end

  def get_currency(value)
    ApplicationController.helpers.get_currency(value, Const::CURRENCY[supply_order_item.product_supply_order.exchange_before_type_cast.to_i], 0)
  end

  private

  def income_locations_count_check
    unless self.is_income_order.present?
      s = 0
      self.income_locations.each do |location|
        lq = location.quantity
        if lq.present?
          if lq < 0
            errors.add(:income_locations, :greater_than, count: 0)
            return
          end
          s += location.quantity
        end
      end
      s = s + self.problematic if problematic.present?
      if (self.quantity || 0) < s
        errors.add(:income_locations, :over)
      elsif self.quantity > s
        errors.add(:income_locations, :equal_to, count: self.quantity)
      end
    end
  end

  def set_product_balance
    if product_income_balance.present?
      self.product_income_balance.update(
          product: product,
          feature_item: feature_item,
          user_income: product_income.user,
          quantity: -quantity)
    else
      self.product_income_balance = ProductIncomeBalance.create(product: product,
                                                                feature_item: feature_item,
                                                                user_income: product_income.user,
                                                                quantity: -quantity)
    end

    if product_balance.present?
      self.product_balance.update(
          product: product,
          feature_item: feature_item,
          user: product_income.user,
          quantity: quantity
      )
    else
      self.product_balance = ProductBalance.create(product: product,
                                                   feature_item: feature_item,
                                                   user: product_income.user,
                                                   quantity: quantity)
    end

  end

  def set_default
    self.product_income = product_income_product.product_income
  end

  def set_remainder
    self.remainder = ProductIncomeBalance.balance(supply_order_item.product_id) + (quantity_was.presence || 0) if supply_order_item.present?
  end

  def set_is_match
    self.is_match = supply_feature.quantity == quantity
    unless self.is_match
      self.product_income_logs << ProductIncomeLog.new(quantity_was: supply_feature.quantity,
                                                       quantity: quantity,
                                                       owner: product_income.user)
    end

    #   set default location x1y1z1
    self.income_locations << ProductIncomeLocation.new(x: 1, y: 1, z: 1, quantity: quantity)
  end

  def check_match_feature
    # Өнгө размер зөрж ирсэн үед лог үүсгэнэ
    if self.is_income_order.present?
      if feature_item_id_was != feature_item_id || quantity_was != quantity
        self.product_income_product.set_default
        self.product_income_logs << ProductIncomeLog.new(feature_item_was_id: feature_item_id_was,
                                                         feature_item_id: feature_item_id,
                                                         quantity_was: supply_feature.quantity,
                                                         quantity: quantity,
                                                         owner: product_income.user)
        self.is_match = false
      end
    end

    #   set default location x1y1z1
    if income_locations.present?
      income_location = income_locations.first
      income_location.update_attribute(:quantity, quantity)
    end
  end

end
