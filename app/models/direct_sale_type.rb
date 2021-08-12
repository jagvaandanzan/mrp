class DirectSaleType < ApplicationRecord

  scope :order_code, ->() {
    order(:code)
  }

  def full_name
    "#{code} - #{name}"
  end

end
