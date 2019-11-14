class ProductFeature < ApplicationRecord
  acts_as_paranoid

  after_create -> {sync_web('post')}
  after_update -> {sync_web('patch')}
  after_destroy -> {sync_web('delete')}

  has_many :options, -> {order(:queue).order(:name)}, :class_name => "ProductFeatureOption", :foreign_key => "product_feature_id", dependent: :destroy

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
    if method == 'delete'
      params = {method: method, id: id}
    else
      params = {method: method, id: id, queue: queue, name: name, description: description}
      method = 'post'
    end

    response = ApplicationController.helpers.api_request('product/features', method, params)
    if response.code.to_i == 200
      Rails.logger.debug(response.body.to_s)
      data = MultiJson.load(response.body)
    end

  end
end
