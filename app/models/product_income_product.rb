class ProductIncomeProduct < ApplicationRecord
  belongs_to :product_income
  belongs_to :shipping_ub_product, optional: true
  belongs_to :shipping_ub_sample, optional: true
  belongs_to :product_supply_order, optional: true
  belongs_to :product

  attr_accessor :remainder

  has_many :product_income_items, dependent: :destroy
  has_many :supply_features, through: :product_income_items
  has_one :shipping_er_product, through: :shipping_ub_product

  accepts_nested_attributes_for :product_income_items, allow_destroy: true

  before_save :set_default

  with_options :if => Proc.new {|m| m.shipping_ub_product_id.present?} do
    validates :cargo, presence: true
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

  # def set_income_item
  #   was_ids = self.product_income_items.map(&:shipping_ub_feature_id).to_a
  #   new_ids = shipping_ub_product.shipping_ub_features.find_to_incomes(was_ids).map(&:id).to_a
  #   self.product_income_items.by_ids(was_ids - new_ids).destroy_all
  #
  #   q_sum = 0
  #   shipping_ub_product.shipping_ub_features.find_to_incomes(was_ids).each do |f|
  #     is_break = false
  #     rem = f[:remainder]
  #     product_income_item = nil
  #     if was_ids.include?(f.id)
  #       product_income_items = self.product_income_items
  #                                  .by_shipping_ub_feature(f.id)
  #       product_income_item = product_income_items.first
  #       rem += product_income_item.quantity
  #     end
  #     q = if q_sum + rem <= self.quantity
  #           q_sum += rem
  #           rem
  #         else
  #           is_break = true
  #           self.quantity - q_sum
  #         end
  #
  #     if was_ids.include?(f.id)
  #       product_income_item.update_column(:quantity, q) unless product_income_item.nil?
  #     else
  #       self.product_income_items << ProductIncomeItem.new(is_income_order: true,
  #                                                          shipping_ub_feature: f,
  #                                                          product_income: product_income,
  #                                                          product: product,
  #                                                          supply_feature: f.supply_feature,
  #                                                          feature_item: f.feature_item,
  #                                                          quantity: q)
  #     end
  #     break if is_break
  #   end
  # end

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
        pi = self.product_income
        v = if shipping_ub_product.present?
              c = shipping_er_product.shipping_er.per_price
              c += shipping_ub_product.per_price
              (c * self[:exc_rate]) + pi.cargo_price / pi.sum_quantity
            else
              (shipping_ub_sample.cost * self[:exc_rate]) / pi.sum_quantity
            end

        self.update_column(:cost, v)
        v
      else
        0
      end
    end

  end

  private

  def set_default
    q = 0
    product_income_items.each do |item|
      q += item.quantity
    end
    self.quantity = q

  end
end
