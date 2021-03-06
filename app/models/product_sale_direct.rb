class ProductSaleDirect < ApplicationRecord
  acts_as_paranoid

  belongs_to :salesman
  belongs_to :product
  belongs_to :feature_item, -> {with_deleted}, :class_name => "ProductFeatureItem"
  belongs_to :sale_item, :class_name => "ProductSaleItem"

  has_one :product_balance, :class_name => "ProductBalance", :foreign_key => "sale_direct_id", dependent: :destroy
  has_one :bonus_balance, dependent: :destroy

  before_save :set_defaults
  before_save :set_product_balance
  validates :product_id, :feature_item_id, :price, :quantity, presence: true
  validates :quantity, :price, numericality: {greater_than: 0}
  validates_numericality_of :quantity, less_than_or_equal_to: Proc.new(&:remainder)
  validates :phone, numericality: {greater_than_or_equal_to: 80000000, less_than_or_equal_to: 99999999, only_integer: true, message: :invalid}

  attr_accessor :remainder

  scope :by_salesman_id, ->(salesman_id) {
    where(salesman_id: salesman_id)
  }
  scope :date_between, ->(date) {
    where('created_at >= ?', date)
        .where('created_at < ?', date + 1.days)
  }
  scope :by_phone, ->(phone) {
    where(phone: phone)
  }

  def price
    ApplicationController.helpers.get_f(self[:price])
  end

  def sum_price
    ApplicationController.helpers.get_f(self[:sum_price])
  end

  def get_balance
    feature_item.balance
  end

  def product_image
    feature_item.img
  end

  def product_size
    feature_item.name
  end

  private

  def set_defaults
    self.sum_price = if price.present? && quantity.present?
                       price * quantity
                     else
                       0
                     end
  end

  def add_bonus
    # 2 дахь худалдан авалтаас бонус бодно
    sales = ProductSale.by_status('sals_delivered')
                .by_phone(phone)
                .count
    sales += DirectSale.by_phone(phone)
                 .count
    sales += ProductSaleDirect.by_phone(phone)
                 .count
    if sales > 1
      bonu = Bonu.by_phone(phone)
      b_model = if bonu.present?
                  bonu.first
                else
                  b = Bonu.new(balance: 0)
                  b.bonus_phones << BonusPhone.new(phone: phone)
                  b.save
                  b
                end
      if bonus_balance.present?
        self.bonus_balance.update(bonu: b_model, bonus: ApplicationController.helpers.get_percentage(quantity * price, 5))
      else
        self.bonus_balance = BonusBalance.create(bonu: b_model, direct_sale_item: self, bonus: ApplicationController.helpers.get_percentage(quantity * price, 5))
      end
    end
  end

  def set_product_balance
    if product_balance.present?
      self.product_balance.update(
          product: product,
          feature_item: feature_item,
          quantity: -quantity)
    else
      self.product_balance = ProductBalance.create(product: product,
                                                   feature_item: feature_item,
                                                   quantity: -quantity)

    end

    sale_item_balances = ProductBalance.by_sale_item(feature_item_id, sale_item_id)
    if sale_item_balances.present?
      sale_item_balance = sale_item_balances.first
      sale_item_quantity = sale_item.quantity - quantity
      # Rails.logger.debug("sale_item_quantity==" + sale_item_quantity.to_s)
      if sale_item_quantity == 0
        sale_item_balance.destroy
      else
        sale_item_balance.quantity = sale_item_quantity
        sale_item_balance.save
      end
    end

    # sale_item.update_columns(back_quantity: sale_item.back_quantity.present? ? sale_item.back_quantity + quantity : quantity)
    sale_item.update_column(:quantity, sale_item.quantity + quantity)
  end

end
