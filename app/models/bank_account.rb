class BankAccount < ApplicationRecord

  validates :name, :account, presence: true, length: {maximum: 255}
  validates :code, presence: true

  def full_name
    "#{code} - #{name}"
  end

  def account_name
    "#{name} #{account}"
  end
end
