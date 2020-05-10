class BankAccount < ApplicationRecord
  def full_name
    "#{name} #{account}"
  end
end
