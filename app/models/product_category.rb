class ProductCategory < ApplicationRecord
  acts_as_paranoid

  has_many :children, :class_name => "ProductCategory", :foreign_key => "parent_id"
  belongs_to :parent, -> {with_deleted}, :class_name => "ProductCategory", optional: true
  belongs_to :cross, -> {with_deleted}, :class_name => "ProductCategory", optional: true

  has_many :products, :class_name => "Product", :foreign_key => "category_id"
  has_many :category_filter_groups, dependent: :destroy

  accepts_nested_attributes_for :category_filter_groups, allow_destroy: true

  has_attached_file :image, :path => ":rails_root/public/product/image/:id_partition/:style.:extension", styles: {original: "1200x1200>", tumb: "400x400>"}, :url => '/product/image/:id_partition/:style.:extension'
  validates_attachment :image,
                       content_type: {content_type: ["image/jpeg", "image/jpg", "image/x-png", "image/png"], message: :content_type}

  after_create -> {sync_web('post')}
  after_update -> {sync_web('update')}, unless: Proc.new {self.method_type == "sync"}
  after_destroy -> {sync_web('delete')}
  attr_accessor :method_type

  validates :queue, :name, :code, presence: true
  validates :code, uniqueness: true

  scope :search, ->(p_id) {
    items = where(parent_id: p_id)
    items.order(:queue)
        .order(:name)
  }
  scope :upd, ->() {
    where("updated_at is ?", nil)
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

  # def filter_should_be_uniq
  #   uniq_by_filters = product_category_filters.uniq(&:category_filter_group_id)
  #
  #   if product_category_filters.length != uniq_by_filters.length
  #     self.errors.add(:product_category_filters, :taken)
  #   end
  # end

  def sync_web(method)
    self.method_type = method
    url = "categories/product"
    if method == 'delete'
      params = nil
      url += "/" + id.to_s
    else
      params = self.to_json(methods: [:method_type], only: [:id, :queue, :name, :name_en, :code, :parent_id, :is_clothes])
    end

    response = ApplicationController.helpers.api_request(url, method, params)
    if response.code.to_i == 201
      self.update_attributes(sync_at: Time.now, method_type: 'sync')
    end
  end

end
