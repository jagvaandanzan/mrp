class ProductFeatureOption < ApplicationRecord
  acts_as_paranoid

  belongs_to :group, :class_name => "ProductFeatureGroup", optional: true
  belongs_to :product_feature
  has_many :product_feature_option_rels, :class_name => "ProductFeatureOptionRel", :foreign_key => "feature_option_id", dependent: :destroy

  after_create -> {sync_web('post')}
  after_update -> {sync_web('update')}, unless: Proc.new {self.method_type == "sync"}
  after_destroy -> {sync_web('delete')}
  attr_accessor :method_type

  validates :queue, :name, presence: true

  scope :order_queue, -> {
    order(:queue)
        .order(:name)
  }

  scope :by_is_feature_ids, ->(ids, is_feature) {
    joins(:product_feature)
        .where("product_features.feature_type=?", is_feature)
        .where("product_feature_options.id IN (?)", ids)
  }
  scope :by_group_id, ->(id) {
    where(group_id: id)
  }

  scope :search, ->(f_id, sname, group_id) {
    items = where(product_feature_id: f_id)
    items = items.where(group_id: group_id) if group_id.present?
    items = items.where('name LIKE :value', value: "%#{sname}%") if sname.present?
    items.order_queue
  }

  scope :by_ids, ->(ids) {
    where("id IN (?)", ids)
  }

  private

  def sync_web(method)
    self.method_type = method
    url = "product/feature_option"

    if method == 'delete'
      params = nil
      url += "/" + id.to_s
    else
      params = self.to_json(methods: [:method_type], only: [:id, :group_id, :queue, :name, :name_en, :code, :product_feature_id])
    end

    response = ApplicationController.helpers.api_request(url, method, params)
    if response.code.to_i == 201
      self.update_columns(sync_at: Time.now, method_type: 'sync')
    end
  end
end
