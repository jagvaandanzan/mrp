class StoreTransferItem < ApplicationRecord
  belongs_to :store_transfer
  belongs_to :product
  belongs_to :feature_item, :class_name => "ProductFeatureItem"
  belongs_to :product_location, optional: true
  has_one :product_balance, :class_name => "ProductBalance", :foreign_key => "transfer_item_id", dependent: :destroy
  has_many :store_transfer_balances, :class_name => "StoreTransferBalance", :foreign_key => "transfer_item_id", dependent: :destroy

  before_validation :set_remainder
  validates :quantity, presence: true
  validates_numericality_of :quantity, less_than_or_equal_to: Proc.new(&:remainder)
  validates :quantity, numericality: {greater_than: 0}

  before_save :set_default
  before_save :set_product_balance

  attr_accessor :remainder

  private

  def set_default
    self.sum_price = quantity * price
  end

  def set_product_balance
    if quantity > 0
      if store_transfer.store_from_id == 1 || store_transfer.store_to_id == 1
        q = store_transfer.store_from_id == 1 ? -quantity : quantity
        if product_balance.present?
          self.product_balance.update_column(:quantity, q)
        else
          self.product_balance = ProductBalance.new(product: product,
                                                    feature_item: feature_item,
                                                    user: store_transfer.user,
                                                    quantity: q)
        end
        if store_transfer_balances.present?
          self.store_transfer_balances.first.update_column(:quantity, q)
        else
          self.store_transfer_balances << StoreTransferBalance.new(product: product,
                                                                   feature_item: feature_item,
                                                                   storeroom: store_transfer.store_from_id == 1 ? store_transfer.store_to : store_transfer.store_from,
                                                                   user: store_transfer.user,
                                                                   quantity: q * (-1))
        end
      else
        # Төв агуулах оролцоогүй бол
        if store_transfer_balances.present?
          store_from_balance = StoreTransferBalance.by_storeroom(product_id, feature_item_id, store_transfer.store_from_id, self.id)
          store_to_balance = StoreTransferBalance.by_storeroom(product_id, feature_item_id, store_transfer.store_to_id, self.id)

          store_from_balance.update_column(:quantity, -quantity)
          store_to_balance.update_column(:quantity, quantity)
        else
          self.store_transfer_balances << StoreTransferBalance.new(product: product,
                                                                   feature_item: feature_item,
                                                                   storeroom: store_transfer.store_from,
                                                                   user: store_transfer.user,
                                                                   quantity: -quantity)
          self.store_transfer_balances << StoreTransferBalance.new(product: product,
                                                                   feature_item: feature_item,
                                                                   storeroom: store_transfer.store_to,
                                                                   user: store_transfer.user,
                                                                   quantity: quantity)
        end
      end
    end
  end

  def set_remainder
    self.remainder = if product_id.present? && feature_item_id.present? && feature_item.balance
                       if store_transfer.store_from_id == 1
                         feature_item.balance + (quantity_was.presence || 0)
                       else
                         StoreTransferBalance.balance_sum(product_id, feature_item_id, store_transfer.store_from_id) + (quantity_was.presence || 0)
                       end
                     else
                       0
                     end
  end
end
