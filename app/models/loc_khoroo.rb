class LocKhoroo < ApplicationRecord
  belongs_to :loc_district

  validates :name, :queue, presence: true

  after_create -> {sync_web('post')}
  after_update -> {sync_web('update')}, unless: Proc.new {self.method_type == "sync"}
  after_destroy -> {sync_web('delete')}
  attr_accessor :method_type

  scope :order_name, ->() {
    order(:queue)
        .order(:name)
  }

  scope :search, ->(district_id, sname) {
    items = where(loc_district_id: district_id)
    items = items.where('name LIKE ?', "%#{sname}%") if sname.present?
    items.order_name
  }

  scope :by_district_id, ->(district_id) {
    where(loc_district_id: district_id)
  }

  def full_name
    name
  end

  private

  def sync_web(method)
    self.method_type = method
    url = "resources/loc_khoroo"
    if method == 'delete'
      params = nil
      url += "/" + id.to_s
    else
      params = self.to_json(methods: [:method_type], only: [:id, :loc_district_id, :name, :queue, :latitude, :longitude])
    end

    ApplicationController.helpers.api_request(url, method, params)
  end
end
