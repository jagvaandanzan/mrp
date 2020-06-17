class TechnicalSpecItem < ApplicationRecord
  belongs_to :technical_specification

  validates :specification, presence: true, length: {maximum: 255}

  scope :order_specification, ->() {
    order(:specification)
  }

  scope :by_group_id, ->(gr_id) {
    where(technical_specification_id: gr_id)
  }

end