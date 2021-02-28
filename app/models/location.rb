class Location < ApplicationRecord
  belongs_to :operator, optional: true
  belongs_to :loc_khoroo
  belongs_to :station, :class_name => "Location", optional: true

  has_many :location_travels, :foreign_key => "location_from_id", dependent: :destroy
  has_many :location_travels, :foreign_key => "location_to_id", dependent: :destroy
  has_many :salesman_travel_routes, dependent: :destroy
  has_many :product_sales
  has_one :loc_district, through: :loc_khoroo

  before_save :set_lng_lat
  enum distance: {distance_a: 0, distance_b: 1, distance_c: 2, distance_d: 3}

  validates :distance, :loc_khoroo, presence: true
  validates :name, :name_la, presence: true

  with_options :if => Proc.new {|m| m.loc_khoroo.loc_district.country} do
    validates :station_id, presence: true
  end

  validates_uniqueness_of :name, :name_la, scope: [:loc_khoroo_id]

  scope :search, ->(khoroo_id, sname) {
    items = where(loc_khoroo_id: khoroo_id)
    items = items.where('name LIKE :value OR name_la LIKE :value', value: "%#{sname}%") if sname.present?
    items.order(:name)
  }

  scope :search_by_name, ->(name, country) {
    items = joins(:loc_district)
    items = if country == "true"
              items.where('loc_districts.name LIKE :value OR loc_khoroos.name LIKE :value OR locations.name LIKE :value OR locations.name_la LIKE :value', value: "%#{name}%")
                  .where("loc_districts.country = ?", true)
            else
              items.where('locations.name LIKE :value OR locations.name_la LIKE :value', value: "%#{name}%")
                  .where("loc_districts.country = ?", false)
            end
    items.order(:name)
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

  scope :by_country, ->() {
    where(country: true)
        .order(:name)
  }

  scope :search_by_country, ->() {
    joins(:loc_district)
        .where("loc_districts.country = ?", true)
        .order(:name)
  }

  def full_name
    loc_khoroo.loc_district.name + ", " + loc_khoroo.name + ", " + name
  end

  private

  def set_lng_lat
    if station_id.present?
      self.latitude = station.latitude
      self.longitude = station.longitude
      self.distance = station.distance
    end
  end
end
