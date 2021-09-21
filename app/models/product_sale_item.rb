class ProductSaleItem < ApplicationRecord
  acts_as_paranoid
  belongs_to :product_sale
  belongs_to :product
  belongs_to :feature_item, -> {with_deleted}, :class_name => "ProductFeatureItem"
  belongs_to :log_stat, optional: true

  has_one :product_balance, :class_name => "ProductBalance", :foreign_key => "sale_item_id", dependent: :destroy
  has_one :bonus_balance, dependent: :destroy
  has_many :salesman_returns, :class_name => "SalesmanReturn", :foreign_key => "sale_item_id", dependent: :destroy
  has_one :salesman_travel, through: :product_sale
  has_one :status, through: :product_sale
  has_one :salesman_travel_route, through: :product_sale
  has_many :product_sale_status_logs, through: :product_sale
  has_many :product_sale_returns, through: :product_sale

  before_save :set_product_balance

  validates :product_id, :feature_item_id, :price, :quantity, presence: true
  validates :price, numericality: {greater_than: 0}
  validates_numericality_of :quantity, less_than_or_equal_to: Proc.new(&:remainder)
  validates :quantity, numericality: {greater_than: 0}

  before_validation :set_remainder
  attr_accessor :remainder, :p_price, :p_6_8, :p_9_

  scope :find_by_salesman_id, ->(feature_item_id, salesman_id) {
    joins(:salesman_travel)
        .where("salesman_travels.salesman_id = ?", salesman_id)
        .where(feature_item_id: feature_item_id)
        .where("quantity - IFNULL(bought_quantity, 0) - IFNULL(back_quantity, 0) > ?", 0)
  }
  scope :by_salesman_travel_id, ->(salesman_travel_id) {
    joins(:salesman_travel)
        .where("salesman_travels.id = ?", salesman_travel_id)
  }
  scope :sale_available, ->(salesman_id) {
    joins(:salesman_travel)
        .joins(:product)
        .where("salesman_travels.salesman_id = ?", salesman_id)
        .where("quantity - IFNULL(bought_quantity, 0) - IFNULL(back_quantity, 0) > ?", 0)
        .order("products.code")
        .order("products.n_name")
  }

  scope :status_not_confirmed, ->() {
    joins(:status)
        .where.not('product_sale_statuses.alias = ?', 'oper_confirmed')
  }

  scope :count_item_quantity, ->(travel_id) {
    joins(:salesman_travel)
        .where("salesman_travels.id = ?", travel_id)
        .sum(:quantity)
  }

  scope :not_nil_bought_quantity, ->() {
    where("bought_quantity IS NOT ?", nil)
  }

  scope :not_buy_by_travel_ids, ->(travel_ids) {
    joins(:salesman_travel)
        .where("salesman_travels.id IN (?)", travel_ids)
        .where("bought_quantity IS ?", nil)
  }
  scope :is_quantity_lower, ->(n) {
    where("product_sale_items.quantity < ?", n)
  }
  scope :by_to_see, ->(to_see) {
    where(to_see: to_see)
  }
  scope :by_id, ->(id) {
    where(id: id)
  }
  scope :by_feature_item_id, ->(feature_item_id) {
    where(feature_item_id: feature_item_id)
  }

  scope :sum_price_by_salesman, ->(salesman_id, start_time, end_time) {
    joins(:salesman_travel)
        .where("salesman_travels.salesman_id = ?", salesman_id)
        .where("bought_quantity IS NOT ?", nil)
        .where("bought_quantity > ?", 0)
        .where('salesman_travels.delivered_at IS NOT ?', nil)
        .where('salesman_travels.delivered_at >= ?', start_time)
        .where('salesman_travels.delivered_at < ?', end_time + 1.days)
        .sum("bought_quantity * price")
  }

  def price
    ApplicationController.helpers.get_f(self[:price])
  end

  def sum_price
    ApplicationController.helpers.get_f(self[:sum_price])
  end

  def product_image
    feature_item.img
  end

  def product_feature
    feature_item.name
  end

  def product_name
    product.name
  end

  def product_code
    product.code
  end

  def product_full_name
    product_name + ", " + product_feature
  end

  def phone
    product_sale.phone
  end

  def product_barcode
    feature_item.barcode
  end

  def back_request
    salesman_returns.count > 0
  end

  def sale_type
    product_sale.parent_id.present? ? product_sale.parent.status.name : 'Захиалга'
  end

  def return_signed
    if salesman_returns.present?
      salesman_return = salesman_returns.first
      salesman_return.sign_id.present?
    else
      false
    end
  end

  def add_bonus
    if bought_quantity.present?
      bonu = Bonu.by_phone(product_sale.phone)
      b_model = if bonu.present?
                  bonu.first
                else
                  b = Bonu.new(balance: 0)
                  b.bonus_phones << BonusPhone.new(phone: product_sale.phone)
                  b.save
                  b
                end
      if bonus_balance.present?
        self.bonus_balance.update(bonu: b_model, bonus: ApplicationController.helpers.get_percentage(bought_quantity * price, 5))
      else
        self.bonus_balance = BonusBalance.create(bonu: b_model, product_sale_item: self, bonus: ApplicationController.helpers.get_percentage(bought_quantity * price, 5))
      end
    end
  end

  def discount_price
    if discount.present?
      discount
    else
      (p_discount.present? && price.present?) ? ApplicationController.helpers.get_percentage(price, p_discount) : ''
    end
  end

  def destroy_from(q, user, status_id)
    self.update_columns(log_stat_id: status_id, destroy_q: q)
    del_q = q
    if q < quantity
      del_q = quantity - q
      self.update_attributes(remainder: del_q, quantity: del_q, sum_price: del_q * price)
    else
      self.destroy
    end
    salesman_id = salesman_travel.salesman_id
    ProductSaleLog.create(user: user,
                          log_stat_id: status_id,
                          salesman_id: salesman_id,
                          salesman_travel_id: salesman_travel.id,
                          product_sale_id: product_sale_id,
                          sale_item: self,
                          product_id: product_id,
                          feature_item_id: feature_item_id,
                          quantity: del_q,
                          to_see: to_see,
                          p_discount: p_discount,
                          discount: discount)
    self.product_sale.update_sum_price
    st = ProductSaleStatus.find_by_alias("auto_destroy")
    self.product_sale.update_column(:status_id, st.id)
    ProductSaleStatusLog.create(product_sale: product_sale,
                                user: user,
                                salesman_id: salesman_id,
                                status: st)
  end

  private

  def set_product_balance
    if quantity > 0
      if product_balance.present?
        self.product_balance.update_attributes(product: product,
                                               feature_item: feature_item,
                                               quantity: -quantity)
      else
        self.product_balance = ProductBalance.new(product: product,
                                                  feature_item: feature_item,
                                                  operator: product_sale.created_operator,
                                                  quantity: -quantity)
      end
    end
  end

  def set_remainder
    self.remainder = if feature_item.present? && feature_item.balance.present?
                       feature_item.balance + (quantity_was.presence || 0) if product_id.present? && feature_item_id.present?
                     else
                       0
                     end
  end

end
