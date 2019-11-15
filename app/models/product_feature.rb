class ProductFeature < ApplicationRecord
  acts_as_paranoid

  has_many :options, -> {order(:queue).order(:name)}, :class_name => "ProductFeatureOption", :foreign_key => "product_feature_id", dependent: :destroy

  after_create -> {sync_web('post')}
  after_update -> {sync_web('update')}, unless: Proc.new {self.method_type == "sync"}
  after_destroy -> {sync_web('delete')}
  attr_accessor :method_type

  validates :queue, :name, presence: true

  scope :order_by_queue, -> {
    order(:queue).order(:name)
  }

  scope :search, ->(sname) {
    items = order_by_queue
    items = items.where('name LIKE :value', value: "%#{sname}%") if sname.present?
    items
  }

  private

  def sync_web(method)
    self.method_type = method
    url = "product/feature"
    if method == 'delete'
      params = nil
      url += "/" + id.to_s
    else
      params = self.to_json(methods: [:method_type], only: [:id, :queue, :name, :description])
    end

    response = ApplicationController.helpers.api_request(url, method, params)
    if response.code.to_i == 201
      self.update(sync_at: Time.now, method_type: 'sync')
    end
  end
end
