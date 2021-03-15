class ShippingUbSample < ApplicationRecord
  belongs_to :shipping_ub

  validates :number, :cost, presence: true

  scope :received_at_nil, -> {
    where("received_at IS ?", nil)
  }
end
