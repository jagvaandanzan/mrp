class Storeroom < ApplicationRecord
  acts_as_paranoid
  belongs_to :product_location

  validates :name, :code, presence: true

  scope :order_code, ->() {
    order(:code)
  }

  scope :not_id, ->(id) {
    where.not(id: id)
  }

  def full_name
    "#{code} - #{name}"
  end

end