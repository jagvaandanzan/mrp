class TechnicalSpecItem < ApplicationRecord
  belongs_to :technical_specification

  validates :technical_specification_id, presence: true
  validates :specification, presence: true, length: {maximum: 255}

  scope :order_specification, ->() {
    order(:specification)
  }

end
