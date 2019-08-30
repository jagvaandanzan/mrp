class LocKhoroo < ApplicationRecord
  belongs_to :loc_district

  validates :name, presence: true

  scope :search, ->(district_id, sname) {
    items = where(loc_district_id: district_id)
    items = items.where('name LIKE ?', "%#{sname}%") if sname.present?
    items.order(:name)
  }
end
