class Location < ApplicationRecord
  belongs_to :operator, optional: true
  belongs_to :loc_district
  belongs_to :loc_khoroo
  belongs_to :station, :class_name => "Location", optional: true

  has_many :location_travels, :foreign_key => "location_from_id", dependent: :destroy
  has_many :location_travels, :foreign_key => "location_to_id", dependent: :destroy
  has_many :salesman_travel_routes, dependent: :destroy
  has_many :product_sales

  before_save :set_lng_lat
  after_update :sync_web
  enum distance: {distance_a: 0, distance_b: 1, distance_c: 2, distance_d: 3}

  attr_accessor :my_id
  validates :loc_district_id, :loc_khoroo_id, presence: true
  validates :name, :name_la, presence: true

  # with_options :if => Proc.new {|m| m.loc_district.country} do
  #   validates :station_id, presence: true
  # end

  validates_uniqueness_of :name, :name_la, scope: [:loc_khoroo_id]

  scope :search, ->(khoroo_id, sname) {
    items = where(loc_khoroo_id: khoroo_id)
    items = items.where('name LIKE :value OR name_la LIKE :value', value: "%#{sname}%") if sname.present?
    items.order(:name)
  }

  scope :search_by_name, ->(name, country) {
    items = left_joins(:loc_district)
                .left_joins(:loc_khoroo)
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
    if name.present?
      "#{loc_district.name}, #{loc_khoroo.name}, #{name}"
    else
      address
    end
  end

  def address
    s = "#{loc_district.name}, #{loc_khoroo.name}"
    s += ", #{micro_region}" if micro_region.present?
    s += ", #{town}" if town.present?
    s += ", #{street}" if street.present?
    s += ", #{apartment}" if apartment.present?
    s += ", #{entrance}" if entrance.present?
    s
  end

  private

  def set_lng_lat
    if station_id.present?
      self.latitude = station.latitude
      self.longitude = station.longitude
      self.distance = station.distance
    end
  end

  def sync_web
    if web_location_id.present?
      update_column(:approved, true)

      url = "sales/location"
      params = {id: web_location_id, mrp_id: self.id}.to_json
      ApplicationController.helpers.api_request(url, 'patch', params)
    end
  end
end
