class CategoryFilterGroup < ApplicationRecord
  acts_as_paranoid
  belongs_to :product_category, optional: true
  has_many :category_filters

  accepts_nested_attributes_for :category_filters, allow_destroy: true

  after_create -> {sync_web('post')}
  after_update -> {sync_web('update')}, unless: Proc.new {self.method_type == "sync"}
  after_destroy -> {sync_web('delete')}
  attr_accessor :method_type

  validates :name, presence: true
  validates_uniqueness_of :name, scope: [:product_category_id]

  scope :order_name, ->() {
    order(:name)
  }
  scope :search_name, ->(name) {
    where('name_en LIKE :value', value: "%#{name}%") if name.present?
  }
  scope :qe_name, ->(name) {
    where('LOWER(name_en) = ?', name) if name.present?
  }

  scope :search, ->(category_id, category_code, category_name, name) {
    items = order_name
    items = items.joins(:product_category) if category_code.present? || category_name.present?
    items = items.where('product_categories.code = ?', category_code) if category_code.present?
    items = items.where('product_categories.name LIKE :value', value: "%#{category_name}%") if category_name.present?
    items = items.where('product_category_id = ?', category_id) if category_id.present?
    items = items.where('name LIKE :value', value: "%#{name}%") if name.present?
    items
  }
  scope :sync_nil, ->() {
    where("id > ?", 13762)
        .where("sync_at IS ?", nil)
  }
  private

  def sync_web(method)
    self.method_type = method
    url = "categories/filter_group"

    if method == 'delete'
      params = nil
      url += "/" + id.to_s
    else
      params = self.to_json(methods: [:method_type], only: [:id, :product_category_id, :name, :name_en],
                            :include => {:category_filters => {
                                methods: [:img_url],
                                only: [:id, :category_filter_group_id, :name, :name_en],
                            }}
      )
    end

    response = ApplicationController.helpers.api_request(url, method, params)
    if response.code.to_i == 201
      self.update_columns(sync_at: Time.now, method_type: 'sync')
    end
  end
end
