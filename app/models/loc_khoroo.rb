class LocKhoroo < ApplicationRecord
  belongs_to :loc_district

  validates :name, :queue, presence: true

  scope :search, ->(district_id, sname) {
    items = where(loc_district_id: district_id)
    items = items.where('name LIKE ?', "%#{sname}%") if sname.present?
    items.order(:queue)
        .order(:name)
  }

  def full_name
    name
  end
end
