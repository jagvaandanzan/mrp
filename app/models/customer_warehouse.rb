class CustomerWarehouse < ApplicationRecord
  belongs_to :customer

  validates :name, presence: true, length: {maximum: 255}
  validates :mo_start, :mo_end, :tu_start, :tu_end, :we_start, :we_end, :th_start, :th_end, :fr_start, :fr_end, :sa_start, :sa_end, :su_start, :su_end, presence: true

  scope :by_customer_id, ->(customer_id) {
    where(customer_id: customer_id)
  }

  def full_name
    name
  end
end
