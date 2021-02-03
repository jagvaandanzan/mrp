class Manufacturer < ApplicationRecord

  validates :country, presence: true, length: {maximum: 255}

  after_create -> {sync_web('post')}
  after_update -> {sync_web('update')}, unless: Proc.new {self.method_type == "sync"}
  after_destroy -> {sync_web('delete')}
  attr_accessor :method_type

  scope :order_country, ->() {
    order(:queue)
        .order(:country)
  }

  scope :search, ->(search_country) {
    items = order_country
    items = items.where('country LIKE :value', value: "%#{search_country}%") if search_country.present?
    items
  }
  private

  def sync_web(method)
    self.method_type = method
    url = "resources/manufacturer"
    if method == 'delete'
      params = nil
      url += "/" + id.to_s
    else
      params = self.to_json(methods: [:method_type], only: [:id, :queue, :country])
    end

    response = ApplicationController.helpers.api_request(url, method, params)
    if response.code.to_i == 201
      self.update_attributes(sync_at: Time.now, method_type: 'sync')
    end
  end

end
