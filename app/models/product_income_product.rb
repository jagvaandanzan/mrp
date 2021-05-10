class ProductIncomeProduct < ApplicationRecord
  belongs_to :product_income
  belongs_to :shipping_er, optional: true
  belongs_to :shipping_ub_product, optional: true
  belongs_to :shipping_ub_sample, optional: true
  belongs_to :product_supply_order, optional: true
  belongs_to :product

  attr_accessor :remainder

  has_many :product_income_items, dependent: :destroy
  has_many :product_income_logs, through: :product_income_items
  has_many :supply_features, through: :product_income_items
  has_one :shipping_er_product, through: :shipping_ub_product

  accepts_nested_attributes_for :product_income_items, allow_destroy: true

  before_save :set_default
  after_save :set_ub_sample

  with_options :if => Proc.new {|m| m.shipping_ub_product_id.present?} do
    validates :cargo, presence: true
  end

  scope :date_desc, -> {
    order(created_at: :desc)
  }

  scope :search, ->(start, finish, product_name, order_type) {
    items = date_desc
    items = items.where('? <= product_income_products.created_at AND product_income_products.created_at <= ?', start.to_time, finish.to_time + 1.days) if start.present? && finish.present?
    items = items.joins(:product).where('products.code LIKE :value OR products.n_name LIKE :value', value: "%#{product_name}%") if product_name.present?
    items = items.where("product_income_products.product_supply_order_id IS#{order_type == "is_basic" ? '' : ' NOT'} ?", nil) if order_type.present?
    items
  }
  scope :by_date, ->(start, finish) {
    joins(:product_income)
        .where('? <= product_incomes.income_date AND product_incomes.income_date <= ?', start.to_time, finish.to_time + 1.days)
  }
  scope :by_calc_nil, ->(is_nil) {
    left_joins(:product_income_items)
        .where("product_income_items.calculated IS#{is_nil == "true" ? '' : ' NOT'} ?", nil)
    # .group("product_income_products.id")
  }
  scope :by_ub_sample_id, ->(ub_sample_id) {
    where(shipping_ub_sample_id: ub_sample_id)
  }
  scope :by_product, ->(product_id) {
    where(product_id: product_id)
  }
  scope :by_supply_order, ->(supply_order_id) {
    where(product_supply_order_id: supply_order_id)
  }

  def sum_not_match
    product_income_items.not_match.count
  end

  def sum_price
    unit_price * quantity
  end

  def unit_price
    if self[:unit_price].present?
      self[:unit_price]
    else
      p = supply_features
              .average(:price_lo)
      p = 0 if p.nil?
      self.update_column(:unit_price, p) unless p.nil?
      p
    end
  end

  def items_quantity
    product_income_items.sum(:quantity)
  end

  # def exc_rate
  #   if self[:exc_rate].present?
  #     self[:exc_rate]
  #   else
  #     supply_feature = supply_features.first
  #     if supply_feature.present?
  #       logistic_transactions = LogisticTransaction.by_supply_order_id(supply_feature.order_item_id)
  #       if logistic_transactions.present?
  #         logistic_transaction = logistic_transactions.first
  #         logistic_transaction.exc_rate
  #         self.update_column(:exc_rate, logistic_transaction.exc_rate)
  #         logistic_transaction.exc_rate
  #       else
  #         0
  #       end
  #     else
  #       0
  #     end
  #   end
  # end

  def cost
    if self[:cost].present?
      self[:cost]
    else
      c = product_income_items.sum_shipping_er_cost + product_income_items.sum_shipping_ub_product_cost + product_income_items.sum_shipping_ub_sample_cost
      self.update_column(:cost, c)
      c
    end

  end

  def set_default
    q = 0
    product_income_items.each do |item|
      q += item.quantity
    end
    self.quantity = q

    self.shipping_er_id = shipping_er_product.shipping_er_id if shipping_er_product.present?
  end

  private

  def set_ub_sample
    if shipping_ub_sample.present?
      shipping_ub_sample.update_column(:received_at, Time.current) unless shipping_ub_sample.received_at.present?
    end
  end
end
