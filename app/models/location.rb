class Location < ApplicationRecord
  belongs_to :user
  belongs_to :loc_khoroo
  has_many :location_travels, :foreign_key => "location_from_id", dependent: :destroy
  has_many :location_travels, :foreign_key => "location_to_id", dependent: :destroy

  validates :name, presence: true

  scope :search, ->(khoroo_id, sname) {
    items = where(loc_khoroo_id: khoroo_id)
    items = items.where('name LIKE :value OR name_la LIKE :value', value: "%#{sname}%") if sname.present?
    items.order(:name)
  }

  def full_name
    loc_khoroo.loc_district.name + ", " + loc_khoroo.name + ", " + name
  end
end
