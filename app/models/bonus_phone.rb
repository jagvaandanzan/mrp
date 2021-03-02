class BonusPhone < ApplicationRecord
  belongs_to :bonu

  validates :phone, presence: true
  validates :phone, numericality: {greater_than_or_equal_to: 80000000, less_than_or_equal_to: 99999999, only_integer: true, message: :invalid}

  validates_uniqueness_of :phone
end
