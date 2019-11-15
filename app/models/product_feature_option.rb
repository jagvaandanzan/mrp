class ProductFeatureOption < ApplicationRecord
  acts_as_paranoid

  belongs_to :product_feature
  has_many :product_feature_option_rels, :class_name => "ProductFeatureOptionRel", :foreign_key => "feature_option_id", dependent: :destroy

  after_create -> {sync_web('post')}
  after_update -> {sync_web('update')}, unless: Proc.new {self.method_type == "sync"}
  after_destroy -> {sync_web('delete')}
  attr_accessor :method_type

  validates :queue, :name, presence: true

  scope :search, ->(f_id, sname) {
    items = where(product_feature_id: f_id)
    items = items.where('name LIKE :value', value: "%#{sname}%") if sname.present?
    items.order(:queue)
        .order(:name)
  }

  private

  def sync_web(method)
    self.method_type = method
    url = "product/feature_option"

    if method == 'delete'
      params = nil
      url += "/" + id.to_s
    else
      params = self.to_json(methods: [:method_type], only: [:id, :queue, :name, :product_feature_id])
    end

    response = ApplicationController.helpers.api_request(url, method, params)
    if response.code.to_i == 201
      self.update(sync_at: Time.now, method_type: 'sync')
    end
  end
end
