class ProductCategory < ApplicationRecord
  acts_as_paranoid

  has_many :children, :class_name => "ProductCategory", :foreign_key => "parent_id"
  belongs_to :parent, -> {with_deleted}, :class_name => "ProductCategory", optional: true

  has_many :products, :class_name => "Product", :foreign_key => "category_id"
  has_many :product_category_filters, dependent: :destroy

  accepts_nested_attributes_for :product_category_filters, allow_destroy: true

  # after_create -> {sync_web('post')}
  # after_update -> {sync_web('update')}, unless: Proc.new {self.method_type == "sync"}
  # after_destroy -> {sync_web('delete')}
  attr_accessor :method_type

  validates :queue, :name, :code, presence: true
  validates :code, uniqueness: true
  validate :filter_should_be_uniq

  scope :search, ->(p_id) {
    items = where(parent_id: p_id)
    items.order(:queue)
        .order(:name)
  }

  scope :order_by, ->() {
    order(:queue)
        .order(:name)
  }

  scope :top_level, ->() {
    items = where(parent_id: nil)
    items.order(:queue)
        .order(:name)
  }


  scope :get_children, ->(p_id) {
    if p_id.presence
      items = where(parent_id: p_id)
    else
      items = where(parent_id: nil)
    end

    items.order(:name)
  }

  private

  def filter_should_be_uniq
    uniq_by_filters = product_category_filters.uniq(&:category_filter_group_id)

    if product_category_filters.length != uniq_by_filters.length
      self.errors.add(:product_category_filters, :taken)
    end
  end

  def sync_web(method)
    self.method_type = method
    url = "product/category"
    if method == 'delete'
      params = nil
      url += "/" + id.to_s
    else
      params = self.to_json(methods: [:method_type], only: [:id, :name, :code, :parent_id])
    end

    response = ApplicationController.helpers.api_request(url, method, params)
    if response.code.to_i == 201
      self.update(sync_at: Time.now, method_type: 'sync')
    end
  end

end
