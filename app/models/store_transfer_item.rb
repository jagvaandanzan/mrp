class StoreTransferItem < ApplicationRecord
  belongs_to :store_transfer
  belongs_to :product
  belongs_to :feature_item, :class_name => "ProductFeatureItem"
  belongs_to :product_location
  has_one :product_balance, :class_name => "ProductBalance", :foreign_key => "transfer_item_id", dependent: :destroy
  has_one :product_location_balance, dependent: :destroy
  has_many :store_transfer_balances, :class_name => "StoreTransferBalance", :foreign_key => "transfer_item_id", dependent: :destroy

  before_validation :set_remainder
  validates :quantity, :feature_item_id, :product_location_id, presence: true
  validates_numericality_of :quantity, less_than_or_equal_to: Proc.new(&:remainder)
  validates_numericality_of :quantity, less_than_or_equal_to: Proc.new(&:loc_remainder)
  validates :quantity, numericality: {greater_than: 0}

  before_save :set_default
  before_save :set_product_balance

  attr_accessor :remainder, :loc_remainder

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
        #Төв агуулахаас авсан бол тавиураас нь хасна
        if store_transfer.store_from_id == 1
          if product_location_balance.present?
            self.product_location_balance.update_column(:quantity, q)
          else
            self.product_location_balance = ProductLocationBalance.new(product_location: product_location,
                                                                       product_feature_item: feature_item,
                                                                       quantity: q)
          end
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
    self.loc_remainder = if store_transfer.store_from_id == 1
                           ProductLocationBalance.by_location_id(product_location_id)
                               .by_feature_item_id(feature_item_id)
                               .sum_quantity + (quantity_was.presence || 0)
                         else
                           remainder
                         end
  end
end
