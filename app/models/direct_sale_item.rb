class DirectSaleItem < ApplicationRecord
  belongs_to :direct_sale
  belongs_to :product
  belongs_to :feature_item, :class_name => "ProductFeatureItem"
  belongs_to :product_location
  has_one :product_balance
  has_one :product_location_balance
  has_one :bonus_balance, dependent: :destroy

  before_validation :set_remainder
  validates :quantity, :feature_item_id, :product_location_id, presence: true
  validates_numericality_of :quantity, less_than_or_equal_to: Proc.new(&:remainder)
  validates_numericality_of :quantity, less_than_or_equal_to: Proc.new(&:loc_remainder)
  validates :quantity, numericality: {greater_than: 0}

  before_save :set_default
  before_save :set_product_balance

  attr_accessor :remainder, :loc_remainder

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

      if product_location_balance.present?
        self.product_location_balance.update_column(:quantity, q)
      else
        self.product_location_balance = ProductLocationBalance.new(product_location: product_location,
                                                                   product_feature_item: feature_item,
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
    self.loc_remainder = ProductLocationBalance.by_location_id(product_location_id)
                             .by_feature_item_id(feature_item_id)
                             .sum_quantity + (quantity_was.presence || 0)
  end
end
