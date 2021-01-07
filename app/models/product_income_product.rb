class ProductIncomeProduct < ApplicationRecord
  belongs_to :product_income
  belongs_to :shipping_ub_product
  belongs_to :product

  attr_accessor :remainder

  before_save :set_income_item
  has_many :product_income_items, :class_name => "ProductIncomeItem", foreign_key: "income_product_id", dependent: :destroy
  has_many :supply_features, through: :product_income_items
  has_one :shipping_er_product, through: :shipping_ub_product

  validates :quantity, :cargo, presence: true
  with_options :if => Proc.new {|m| m.remainder.present?} do
    validates_numericality_of :quantity, less_than_or_equal_to: Proc.new(&:remainder)
  end
  scope :date_desc, -> {
    order(created_at: :desc)
  }

  scope :search, ->(start, finish, product_name) {
    items = date_desc
    items = items.where('? <= product_incomes.income_date AND product_incomes.income_date <= ?', start.to_time, finish.to_time + 1.days) if start.present? && finish.present?
    items = items.joins(:product).where('products.code LIKE :value OR products.n_name LIKE :value', value: "%#{product_name}%") if product_name.present?
    items
  }

  def set_income_item
    self.product_income_items.destroy_all
    q_sum = 0
    shipping_ub_product.shipping_ub_features.find_to_incomes.each do |f|
      is_break = false
      q = if q_sum + f[:remainder] <= self.quantity
            q_sum += f[:remainder]
            f[:remainder]
          else
            is_break = true
            self.quantity - q_sum
          end

      self.product_income_items << ProductIncomeItem.new(shipping_ub_feature: f,
                                                         product_income: product_income,
                                                         product: product,
                                                         supply_feature: f.supply_feature,
                                                         feature_item: f.feature_item,
                                                         quantity: q)
      break if is_break
    end
  end

  def unit_price
    if self[:unit_price].present?
      self[:unit_price]
    else
      p = supply_features
              .average(:price_lo)
      self.unit_price = p
      p
    end
  end

  def exc_rate
    if self[:exc_rate].present?
      self[:exc_rate]
    else
      supply_feature = supply_features.first
      logistic_transactions = LogisticTransaction.by_supply_order_id(supply_feature.order_item_id)
      if logistic_transactions.present?
        logistic_transaction = logistic_transactions.first
        logistic_transaction.exc_rate
        self.update_column(:exc_rate, logistic_transaction.exc_rate)
        logistic_transaction.exc_rate
      else
        0
      end
    end
  end

  def cost
    if self[:cost].present?
      self[:cost]
    else
      if self[:exc_rate].present?
        c = shipping_er_product.shipping_er.per_price
        c += shipping_ub_product.per_price
        pi = self.product_income
        v = (c * self[:exc_rate]) + pi.cargo_price / pi.sum_quantity
        self.update_column(:cost, v)
        v
      else
        0
      end
    end

  end

end
