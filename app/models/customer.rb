class Customer < ApplicationRecord
  acts_as_paranoid

  after_create -> {sync_web('post')}
  after_update -> {sync_web('update')}, unless: Proc.new {self.method_type == "sync"}
  after_destroy -> {sync_web('delete')}
  attr_accessor :method_type

  validates :code, :name, :queue, presence: true

  scope :order_by_name, -> {
    order(:queue)
        .order(:name)
  }

  scope :search, ->(sname) {
    items = order_by_name
    items = items.where('name LIKE :value OR code LIKE :value', value: "%#{sname}%") if sname.present?
    items
  }

  private

  def sync_web(method)
    self.method_type = method
    url = "resources/customer"
    if method == 'delete'
      params = nil
      url += "/" + id.to_s
    else
      params = self.to_json(methods: [:method_type], only: [:id, :code, :queue, :name, :description])
    end

    response = ApplicationController.helpers.api_request(url, method, params)
    Rails.logger.info("#{response.body}")
    if response.code.to_i == 201
      self.update_attributes(sync_at: Time.now, method_type: 'sync')
    end
  end

end
