class Location < ApplicationRecord
  belongs_to :operator, optional: true
  belongs_to :loc_khoroo
  has_many :location_travels, :foreign_key => "location_from_id", dependent: :destroy
  has_many :location_travels, :foreign_key => "location_to_id", dependent: :destroy
  has_many :salesman_travel_routes, dependent: :destroy
  has_many :product_sales

  enum distance: {distance_a: 0, distance_b: 1, distance_c: 2, distance_d: 3}

  validates :distance, :loc_khoroo, presence: true
  validates :name, :name_la, presence: true, length: {maximum: 255}

  validates_uniqueness_of :name, :name_la, scope: [:loc_khoroo_id]

  scope :search, ->(khoroo_id, sname) {
    items = where(loc_khoroo_id: khoroo_id)
    items = items.where('name LIKE :value OR name_la LIKE :value', value: "%#{sname}%") if sname.present?
    items.order(:name)
  }

  scope :search_by_name, ->(name) {
    where('name LIKE :value OR name_la LIKE :value', value: "%#{name}%")
        .order(:name)
  }
  scope :search_by_id, ->(id) {
    if id.present?
      where(id: id)
    else
      []
    end
  }
  scope :search_by_ids, ->(ids) {
    where("id IN (?)", ids)
  }
  scope :searchAll, ->() {
    items = where("")
    # items = items.where('name LIKE :value OR name_la LIKE :value', value: "%#{sname}%") if sname.present?
    items.order(:name)
  }

  scope :search_by_country, ->() {
    where(country: true)
        .order(:name)
  }

  def full_name
    loc_khoroo.loc_district.name + ", " + loc_khoroo.name + ", " + name
  end
end
