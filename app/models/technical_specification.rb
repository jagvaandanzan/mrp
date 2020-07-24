class TechnicalSpecification < ApplicationRecord

  has_many :technical_spec_items
  accepts_nested_attributes_for :technical_spec_items, allow_destroy: true

  after_create -> {sync_web('post')}
  after_update -> {sync_web('update')}, unless: Proc.new {self.method_type == "sync"}
  after_destroy -> {sync_web('delete')}
  attr_accessor :method_type

  validates :specification_gr, presence: true, length: {maximum: 255}

  scope :order_specification_gr, ->() {
    order(:specification_gr)
  }

  scope :search, ->(name) {
    items = order_specification_gr
    items = items.where('specification_gr LIKE :value', value: "%#{name}%") if name.present?
    items
  }

  private

  def sync_web(method)
    self.method_type = method
    url = "resources/technical_specification"
    if method == 'delete'
      params = nil
      url += "/" + id.to_s
    else
      params = self.to_json(methods: [:method_type], only: [:id, :specification_gr],
                            :include => {:technical_spec_items => {
                                only: [:id, :technical_specification_id, :specification],
                            }})
    end

    response = ApplicationController.helpers.api_request(url, method, params)
    if response.code.to_i == 201
      self.update_attributes(sync_at: Time.now, method_type: 'sync')
    end
  end

end
