class ProductIncomeItem < ApplicationRecord
  belongs_to :product_income
  belongs_to :product_income_product
  belongs_to :shipping_ub_feature
  belongs_to :supply_feature, :class_name => "ProductSupplyFeature"
  belongs_to :product
  belongs_to :feature_item, :class_name => "ProductFeatureItem"
  has_many :income_locations, :class_name => "ProductIncomeLocation", :foreign_key => "income_item_id", dependent: :destroy

  has_one :product_income_balance, :class_name => "ProductIncomeBalance", :foreign_key => "income_item_id", dependent: :destroy
  has_one :product_balance, :class_name => "ProductBalance", :foreign_key => "income_item_id", dependent: :destroy

  accepts_nested_attributes_for :income_locations, allow_destroy: true

  before_save :set_product_balance
  before_validation :set_default
  # before_validation :set_remainder

  validates :quantity, presence: true
  validates :quantity, numericality: {greater_than: 0}
  with_options :if => Proc.new {|m| m.remainder.present?} do
    validates_numericality_of :quantity, less_than_or_equal_to: Proc.new(&:remainder)
  end
  validate :income_locations_count_check, on: :update
  attr_accessor :is_income_order, :remainder

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
  scope :by_shipping_ub_feature, ->(shipping_ub_feature_id) {
    where(shipping_ub_feature_id: shipping_ub_feature_id)
  }
  scope :by_ids, ->(ids) {
    where("id IN (?)", ids)
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

end
