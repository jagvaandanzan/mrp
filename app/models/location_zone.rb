class LocationZone < ApplicationRecord
  scope :order_queue, ->() {
    order(:queue)
  }
  scope :search, ->(name) {
    items = order(:queue)
    items = items.where('name LIKE :value', value: "%#{name}%") if name.present?
    items
  }

  scope :not_id, ->(id) {
    items = order(:queue)
    items = items.where.not(id: id) unless id.nil?
    items
  }

  scope :by_ids, ->(ids) {
    where("id IN (?)", ids)
  }

end
