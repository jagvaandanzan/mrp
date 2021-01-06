class LogisticTransaction < ApplicationRecord
  belongs_to :bank_transaction
  belongs_to :user
  belongs_to :logistic
  belongs_to :supply_order, :class_name => "ProductSupplyOrder"

  scope :by_supply_order_id, ->(id) {
    where(supply_order: id)
  }
end
