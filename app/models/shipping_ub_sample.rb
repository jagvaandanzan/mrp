class ShippingUbSample < ApplicationRecord
  belongs_to :shipping_ub

  validates :number, :cost, presence: true

  scope :received_at_nil, -> {
    where("received_at IS ?", nil)
  }

  scope :by_date, ->(start, finish) {
    where('? <= created_at AND created_at <= ?', start.to_time, finish.to_time + 1.days)
  }

end
