class DirectSaleItem < ApplicationRecord
  belongs_to :direct_sale
  belongs_to :product
  belongs_to :feature_item, :class_name => "ProductFeatureItem"
  has_one :product_balance
  has_one :bonus_balance, dependent: :destroy

  before_validation :set_remainder
  validates :quantity, presence: true
  validates_numericality_of :quantity, less_than_or_equal_to: Proc.new(&:remainder)
  validates :quantity, numericality: {greater_than: 0}

  before_save :set_default
  before_save :set_product_balance

  attr_accessor :remainder, :desk

  def add_bonus
    bonu = Bonu.by_phone(direct_sale.phone)
    b_model = if bonu.present?
                bonu.first
              else
                b = Bonu.new(balance: 0)
                b.bonus_phones << BonusPhone.new(phone: direct_sale.phone)
                b.save
                b
              end
    if bonus_balance.present?
      self.bonus_balance.update(bonu: b_model, bonus: ApplicationController.helpers.get_percentage(quantity * price, 5))
    else
      self.bonus_balance = BonusBalance.create(bonu: b_model, direct_sale_item: self, bonus: ApplicationController.helpers.get_percentage(quantity * price, 5))
    end
  end

  private

  def set_default
    self.sum_price = quantity * price
    self.pay_price = if discount.present?
                       (sum_price * discount) / 100
                     else
                       sum_price
                     end
  end

  def set_product_balance
    if quantity > 0
      if product_balance.present?
        self.product_balance.update_column(:quantity, -quantity)
      else
        self.product_balance = ProductBalance.new(product: product,
                                                  feature_item: feature_item,
                                                  user: direct_sale.owner,
                                                  quantity: -quantity)
      end
    end
  end

  def set_remainder
    self.remainder = if product_id.present? && feature_item_id.present? && feature_item.balance
                       feature_item.balance + (quantity_was.presence || 0)
                     else
                       0
                     end
  end
end
