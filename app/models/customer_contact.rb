class CustomerContact < ApplicationRecord
  belongs_to :customer

  enum delivery: {deli_we: 0, deli_customer: 1, deli_self: 2}
  enum condition: {limit_less: 0, limit_over: 1}

  validates :delivery, :condition, :price, presence: true


  def uniq_id
    "#{delivery}-#{condition}"
  end

end
