class BankDealingAccount < ApplicationRecord

  validates :name, presence: true, length: {maximum: 255}
  validates :code, presence: true

  def full_name
    "#{code} - #{name}"
  end

end
