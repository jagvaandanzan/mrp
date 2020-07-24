class ProductFeatureGroup < ApplicationRecord
  acts_as_paranoid

  has_many :product_feature_options, :class_name => "ProductFeatureOption", :foreign_key => "group_id", dependent: :destroy

  validates :queue, :name, :code, presence: true

  after_create -> {sync_web('post')}
  after_update -> {sync_web('update')}, unless: Proc.new {self.method_type == "sync"}
  after_destroy -> {sync_web('delete')}
  attr_accessor :method_type

  scope :order_name, -> {
    order(:queue)
        .order(:name)
  }

  scope :search, ->(sname) {
    items = order_name
    items = items.where('name LIKE :value', value: "%#{sname}%") if sname.present?
    items
  }

  def check_option_selected(option_rels)
    arr = product_feature_options.map(&:id).to_a
    !(option_rels.map(&:to_i) & arr).empty?
  end

  private

  def sync_web(method)
    self.method_type = method
    url = "product/feature_group"

    if method == 'delete'
      params = nil
      url += "/" + id.to_s
    else
      params = self.to_json(methods: [:method_type], only: [:id, :queue, :name, :code])
    end

    response = ApplicationController.helpers.api_request(url, method, params)
    if response.code.to_i == 201
      self.update_attributes(sync_at: Time.now, method_type: 'sync')
    end
  end
end
