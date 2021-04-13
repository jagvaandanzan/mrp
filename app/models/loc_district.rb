class LocDistrict < ApplicationRecord
  has_many :loc_khoroos

  validates :name, presence: true

  after_create -> {sync_web('post')}
  after_update -> {sync_web('update')}, unless: Proc.new {self.method_type == "sync"}
  after_destroy -> {sync_web('delete')}
  attr_accessor :method_type

  scope :search, ->() {
    order(:name)
  }

  scope :order_country, ->() {
    order(:country)
        .order(:name)
  }

  private

  def sync_web(method)
    self.method_type = method
    url = "resources/loc_district"
    if method == 'delete'
      params = nil
      url += "/" + id.to_s
    else
      params = self.to_json(methods: [:method_type], only: [:id, :country, :name])
    end

    ApplicationController.helpers.api_request(url, method, params)
  end
end
