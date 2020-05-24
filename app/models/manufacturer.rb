class Manufacturer < ApplicationRecord

  validates :country, presence: true, length: {maximum: 255}

  scope :order_country, ->() {
    order(:queue)
        .order(:country)
  }

  scope :search, ->(search_country) {
    items = order_country
    items = items.where('country LIKE :value', value: "%#{search_country}%") if search_country.present?
    items
  }
end
