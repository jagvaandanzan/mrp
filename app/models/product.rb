class Product < ApplicationRecord
  acts_as_paranoid

  belongs_to :customer, -> {with_deleted}, optional: true
  belongs_to :category, -> {with_deleted}, :class_name => "ProductCategory", optional: true
  belongs_to :brand, optional: true
  belongs_to :manufacturer, optional: true

  has_many :product_names
  has_many :product_feature_option_rels
  has_many :product_feature_items
  has_many :product_instructions
  has_many :product_specifications
  has_many :product_filter_groups
  has_many :product_filters
  has_many :product_photos

  has_many :supply_order_items, :class_name => "ProductSupplyOrderItem", :foreign_key => "product_id"
  has_many :product_sale_items
  has_many :product_sales, through: :product_sale_items
  has_many :salesman_travel, through: :product_sales

  accepts_nested_attributes_for :product_names, allow_destroy: true
  accepts_nested_attributes_for :product_feature_items, allow_destroy: true
  accepts_nested_attributes_for :product_instructions, allow_destroy: true
  accepts_nested_attributes_for :product_specifications, allow_destroy: true
  accepts_nested_attributes_for :product_photos, allow_destroy: true

  enum delivery_type: {is_own: 0, is_customer: 1}
  enum gift_wrap: {wrap_not: 0, wrap_have: 1}

  has_attached_file :size_img, :path => ":rails_root/public/products/size_img/:id_partition/:style.:extension", styles: {original: "1200x1200>", tumb: "400x400>"}, :url => '/products/size_img/:id_partition/:style.:extension'
  validates_attachment :size_img,
                       content_type: {content_type: ["image/jpeg", "image/x-png", "image/png"], message: :content_type}, size: {less_than: 4.megabytes}

  # after_create -> {sync_web('post')}
  # after_update -> {sync_web('update')}, unless: Proc.new {self.method_type == "sync"}
  # after_destroy -> {sync_web('delete')}
  attr_accessor :option_rels, :method_type, :tab_index, :filters

  with_options :if => Proc.new {|m| m.tab_index.to_i == 0} do
    before_validation :set_name
    before_save :set_option_rels
    after_save :set_option_item_single

    validates :name, :category_id, :code, :is_own, presence: true
    validates :product_names, :length => {:minimum => 1}
    validate :valid_option_rels
    validates :code, uniqueness: true
    validate :valid_custom
  end

  with_options :if => Proc.new {|m| m.tab_index.to_i == 0 && m.is_own == 0} do
    validates :customer_id, presence: true
  end

  with_options :if => Proc.new {|m| m.tab_index.to_i == 1} do
    validates :delivery_type, presence: true
  end

  with_options :if => Proc.new {|m| m.tab_index.to_i == 2} do
    before_save :set_filters
    after_save :set_filter_groups
    validates :search_key, :description, presence: true
  end

  with_options :if => Proc.new {|m| m.tab_index.to_i == 3} do
    validate :valid_image_videos
  end

  with_options :if => Proc.new {|m| m.tab_index.to_i == 4} do
    validates :gift_wrap, presence: true
  end

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
        .where("product_sale_items.quantity - IFNULL(product_sale_items.bought_quantity, 0) - IFNULL(product_sale_items.back_quantity, 0) > ?", 0)
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

  def product_feature_option_ids
    option_features = []
    product_feature_option_rels.each do |option_rel|
      option_features << option_rel.feature_option.id
    end

    option_features.to_set
  end

  def product_feature_options(ids, is_feature)
    ProductFeatureOption
        .by_is_feature_ids(ids, is_feature)
        .order_queue
  end

  private

  def valid_custom
    errors.add(:category_id, :blank) if category_id.present? && ProductCategory.search(category_id).count > 0
  end

  def set_name
    name = ""
    product_names.each do |pn|
      name += "#{pn.name}, " if pn.name.present?
    end

    if name.length > 0
      self.name = name[0..(name.length - 3)]
    end
  end

  def valid_option_rels
    self.errors.add(:product_feature_option_rels, :too_short, count: 1) unless option_rels.present?
  end

  def valid_image_videos
    any_img = false
    product_feature_items.each do |p_img_vid|
      any_img = true if p_img_vid.image.present? || p_img_vid.video.present?
    end

    self.errors.add(:product_feature_items, :blank) unless any_img
    self.errors.add(:product_photos, :blank) if photo_web && !product_photos.present?
  end

  def set_option_rels
    if option_rels.present?
      was_option_ids = product_feature_option_rels.map(&:feature_option_id).to_a
      feature_option_rels = option_rels.map(&:to_i)
      delete_ids = was_option_ids - feature_option_rels

      product_feature_items.by_option_ids(delete_ids).destroy_all
      product_feature_option_rels.by_feature_option_ids(delete_ids).destroy_all

      added_feature_items = Hash.new
      (feature_option_rels - was_option_ids).each do |option_id|
        feature_option = ProductFeatureOption.find(option_id)
        self.product_feature_option_rels << ProductFeatureOptionRel.new(feature_option: feature_option)

        if self.product_feature_option_rels.size > 1
          self.product_feature_option_rels.each {|option_rel|
            if option_rel.feature_option_id != option_id
              product_feature_1 = option_rel.feature_option.product_feature
              product_feature_2 = feature_option.product_feature
              # Төрөл нь өөр байх ёстой
              if product_feature_1.feature_type != product_feature_2.feature_type
                # Дараалал түрүүнд байгаа нь эхэндээ байна
                if product_feature_1.queue < product_feature_2.queue
                  option_1 = option_rel.feature_option_id
                  option_2 = option_id
                else
                  option_1 = option_id
                  option_2 = option_rel.feature_option_id
                end

                added_key = "#{option_1}-#{option_2}"
                unless added_feature_items[added_key]
                  self.product_feature_items << ProductFeatureItem.new(option1_id: option_1, option2_id: option_2)
                  added_feature_items[added_key] == "added"
                end
              end
            end
          }
        end
      end
    end
  end

  def set_option_item_single
    if product_feature_items.count == 0 && product_feature_option_rels.count == 1
      product_feature_option = product_feature_option_rels.first
      ProductFeatureItem.create(product: self, option1_id: product_feature_option.feature_option_id, option2_id: product_feature_option.feature_option_id)
    end
  end

  def set_filters
    if filters.present?
      was_filter_ids = product_filters.map(&:category_filter).to_a
      filter_ids = filters.map(&:to_i)

      delete_ids = was_filter_ids - filter_ids

      product_filters.by_filter_ids(delete_ids).destroy_all

      (filter_ids - was_filter_ids).each do |filter_id|
        self.product_filters << ProductFilter.new(category_filter_id: filter_id)
      end
    end
  end

  def set_filter_groups
    has_group = self.product_filter_groups.map {|g| [g.category_filter_group_id.to_s, g]}.to_h

    # Грүпгүй филтер байна уу шалгана
    self.product_filters.each do |filter|
      unless filter.product_filter_group.present?
        group_id = filter.category_filter.category_filter_group_id
        if has_group[group_id].present?
          filter_group = has_group[group_id]
        else
          filter_group = ProductFilterGroup.create(product: self, category_filter_group_id: group_id)
          has_group[group_id] = filter_group
        end
        filter.product_filter_group = filter_group
        filter.save
      end
    end

    # Филтергүй грүпүүдийг устгана
    self.product_filter_groups.each do |gr|
      if gr.product_filters.count == 0
        gr.destroy!
      end
    end
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
