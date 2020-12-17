class ProductIncomeProduct < ApplicationRecord
  belongs_to :product_income
  belongs_to :shipping_ub_product
  belongs_to :product

  attr_accessor :remainder

  before_save :set_income_item
  has_many :product_income_items, :class_name => "ProductIncomeItem", foreign_key: "income_product_id", dependent: :destroy

  validates :quantity, :cargo, presence: true
  validates_numericality_of :quantity, less_than_or_equal_to: Proc.new(&:remainder)

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

end
