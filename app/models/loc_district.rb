class LocDistrict < ApplicationRecord
  has_many :loc_khoroos

  validates :name, presence: true

  scope :search, ->() {
    order(:name)
  }

  scope :order_country, ->() {
    order(:country)
        .order(:name)
  }

end
