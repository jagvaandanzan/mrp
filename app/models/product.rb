class Product < ApplicationRecord
  acts_as_paranoid

  belongs_to :customer, -> {with_deleted}
  belongs_to :category, -> {with_deleted}, :class_name => "ProductCategory", optional: true
  has_many :product_feature_rels
  has_many :supply_order_items, :class_name => "ProductSupplyOrderItem", :foreign_key => "product_id"
  has_many :product_sale_items
  has_many :product_sales, through: :product_sale_items
  has_many :salesman_travel, through: :product_sales

  accepts_nested_attributes_for :product_feature_rels, allow_destroy: true

  after_create -> {sync_web('post')}
  after_update -> {sync_web('update')}, unless: Proc.new {self.method_type == "sync"}
  after_destroy -> {sync_web('delete')}
  attr_accessor :method_type

  validates :name, :category_id, :code, :main_code, :barcode, :customer_id, :measure, :ptype, :product_feature_rels, presence: true

  validates :code, uniqueness: true
  validate :valid_category
  enum measure: {sh: 0, kg: 1}
  enum ptype: {zahialga: 0, deej: 1, damjuulah: 2}

  scope :order_by_name, -> {
    order(:name)
  }

  scope :search, ->(sname) {
    items = order_by_name
    items = items.where('code LIKE :value OR name LIKE :value', value: "%#{sname}%") if sname.present?
    items
  }
  scope :search_by_id, ->(id) {
    if id.present?
      where(id: id)
    else
      []
    end
  }
  scope :sale_available, ->(salesman_id) {
    joins(:salesman_travel)
        .where("salesman_travels.salesman_id = ?", salesman_id)
        .where("product_sale_items.quantity - IFNULL(product_sale_items.bought_quantity, 0) > ?", 0)
        .order(:code)
        .order(:name)
        .group(:id)
  }

  def full_name
    name_with_code
  end

  def name_with_code
    "#{self.code} - #{self.name}"
  end

  private

  def valid_category
    errors.add(:category_id, :blank) if category_id.present? && ProductCategory.search(category_id).count > 0
  end

  def sync_web(method)
    self.method_type = method
    url = "products"
    if method == 'delete'
      params = nil
      url += "/" + id.to_s
    else
      params = self.to_json(methods: [:method_type], except: [:deleted_at, :created_at, :updated_at, :sync_at],
                            :include => {:product_feature_rels => {
                                only: [:id, :product_id, :sale_price, :discount_price, :barcode], :methods => [:image_url],
                                :include => {:product_feature_items => {
                                    only: [:id, :product_id, :feature_rel_id, :feature1_id, :option1_id, :feature2_id, :option2_id], :methods => [:balance]
                                }}
                            }})
    end
    # Rails.logger.debug(params)
    response = ApplicationController.helpers.api_request(url, method, params)
    # Rails.logger.debug(response.code)
    # Rails.logger.debug(response.body)
    if response.code.to_i == 201
      self.update(sync_at: Time.now, method_type: 'sync')
    end
  end
end
