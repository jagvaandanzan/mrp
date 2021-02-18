class CustomerContactFee < ApplicationRecord
  belongs_to :customer

  validates :range_s, :range_e, :percent, presence: true

  validates_uniqueness_of :range_s, :range_e, :percent, scope: [:customer_id]
end
