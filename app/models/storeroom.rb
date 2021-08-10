class Storeroom < ApplicationRecord
  acts_as_paranoid

  validates :name, :code, presence: true

  scope :order_code, ->() {
    order(:code)
  }

  def full_name
    "#{code} - #{name}"
  end

end