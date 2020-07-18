class TechnicalSpecItem < ApplicationRecord
  belongs_to :technical_specification

  after_create -> {sync_web('post')}
  after_update -> {sync_web('update')}, unless: Proc.new {self.method_type == "sync"}
  after_destroy -> {sync_web('delete')}
  attr_accessor :method_type

  validates :specification, presence: true, length: {maximum: 255}

  scope :order_specification, ->() {
    order(:specification)
  }

  scope :by_group_id, ->(gr_id) {
    where(technical_specification_id: gr_id)
  }

  private

  def sync_web(method)
    self.method_type = method
    url = "resources/technical_spec_item"
    if method == 'delete'
      params = nil
      url += "/" + id.to_s
    else
      params = self.to_json(methods: [:method_type], only: [:id, :technical_specification_id, :specification])
    end

    ApplicationController.helpers.api_request(url, method, params)
  end

end
