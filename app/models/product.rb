class Product < ApplicationRecord
  acts_as_paranoid

  belongs_to :customer, -> {with_deleted}, optional: true
  belongs_to :category, -> {with_deleted}, :class_name => "ProductCategory", optional: true
  belongs_to :brand
  belongs_to :manufacturer, optional: true
  belongs_to :technical_specification, optional: true
  belongs_to :user, optional: true

  has_many :product_feature_option_rels
  has_many :product_feature_items, -> {order_is_feature}
  has_many :product_instructions
  has_many :product_specifications
  has_many :product_size_instructions
  has_many :product_filter_groups
  has_many :product_filters
  has_many :product_photos
  has_many :product_images
  has_many :product_videos
  has_many :product_discounts
  has_many :product_balances
  has_many :product_location_balances, through: :product_feature_items
  has_one :product_package

  has_many :supply_order_items, :class_name => "ProductSupplyOrderItem", :foreign_key => "product_id"
  has_many :product_sale_items
  has_many :product_sales, through: :product_sale_items
  has_many :salesman_travel, through: :product_sales

  accepts_nested_attributes_for :product_feature_items, allow_destroy: true
  accepts_nested_attributes_for :product_instructions, allow_destroy: true
  accepts_nested_attributes_for :product_photos, allow_destroy: true
  accepts_nested_attributes_for :product_images, allow_destroy: true
  accepts_nested_attributes_for :product_videos, allow_destroy: true

  enum p_type: {type_sample: 0, type_basic: 1, type_customer: 2}

  after_create -> {sync_web('post')}
  after_update -> {sync_web('update')}, unless: Proc.new {self.method_type == "sync"}
  after_destroy -> {sync_web('delete')}

  attr_accessor :option_rels, :method_type, :tab_index, :filters, :instruction_id, :instruction_val, :specification_id, :specification_val, :deliveries

  has_attached_file :picture, :path => ":rails_root/public/products/picture/:id_partition/:style.:extension", styles: {original: "1200x1200>", tumb: "400x400>"}, :url => '/products/picture/:id_partition/:style.:extension'
  validates_attachment :picture,
                       content_type: {content_type: ["image/jpeg", "image/x-png", "image/png"], message: :content_type}, size: {less_than: 4.megabytes}

  before_validation :set_valid_value
  before_save :set_option_rels, unless: Proc.new {self.method_type == "sync"}
  after_save :set_option_item_single

  with_options :if => Proc.new {|m| m.tab_index.to_i == 0 && !m.draft} do
    validates :n_name, :brand_id, :category_id, :code, presence: true
    validates :code, uniqueness: true
    validate :valid_custom
  end

  with_options :if => Proc.new {|m| m.tab_index.to_i == 0 && !m.is_own} do
    before_save :set_product_type
    validates :customer_id, presence: true
  end

  with_options :if => Proc.new {|m| m.tab_index.to_i == 1 && !m.is_own} do
    validates :delivery_type, presence: true
  end

  with_options :if => Proc.new {|m| m.tab_index.to_i == 1} do
    before_validation :set_instructions
  end

  with_options :if => Proc.new {|m| m.tab_index.to_i == 1 && m.category.is_clothes} do
    validates :product_size_instructions, :length => {:minimum => 1}
  end

  with_options :if => Proc.new {|m| m.tab_index.to_i == 2} do
    before_save :set_specifications
    before_save :set_filters
    after_save :set_filter_groups
    validates :search_key, :manufacturer_id, presence: true
  end

  with_options :if => Proc.new {|m| m.tab_index.to_i == 3} do
    validate :check_image_size
    validate :valid_image_videos
  end

  with_options :if => Proc.new {|m| m.tab_index.to_i == 4} do
    validates :gift_wrap, presence: true
  end
  scope :sync_nil, ->() {
    where("id > ?", 5693)
        .where("is_web = ?", 1)
        .where("draft = ?", 0)
        .where("sync_at IS ?", nil)
  }
  scope :order_by_name, -> {
    order(:n_name)
  }
  scope :by_not_draft, -> {
    where("products.draft = ?", false)
  }

  scope :search_by_name, ->(sname) {
    items = by_not_draft
    items = items.where('code LIKE :value OR n_name LIKE :value', value: "%#{sname}%") if sname.present?
    items.order_by_name
  }
  scope :s_by_name, ->(name) {
    joins(:brand)
        .where('n_model LIKE :value OR n_name LIKE :value OR n_package LIKE :value OR n_material LIKE :value OR n_advantage LIKE :value OR brands.name LIKE :value', value: "%#{name}%") if name.present?
  }
  scope :s_by_code, ->(code) {
    where('code LIKE :value', value: "%#{code}%") if code.present?
  }

  scope :s_by_price_max_min, ->(price_min, price_max) {
    left_joins(:product_feature_items)
        .where("product_feature_items.price >= ?", price_min)
        .where("product_feature_items.price <= ?", price_max)
        .group(:id) if price_min.present? && price_max.present?
  }
  scope :by_customer, ->(customer_id) {
    if customer_id.present?
      if customer_id.to_i == 0
        where("products.customer_id IS ?", nil)
      else
        where("products.customer_id = ?", customer_id)
      end
    end
  }

  scope :by_category, ->(category_id) {
    if category_id.present?
      product_category = ProductCategory.find(category_id)
      ids = product_category.category_ids
      where("products.category_id IN (?)", ids)
    end
  }

  scope :by_balance, ->(balance, barcode, desk) {
    items = order_by_name
    items = items.left_joins(:product_balances)
                .having("#{balance == "true" ? 'SUM(product_balances.quantity) > ?' : 'SUM(product_balances.quantity) IS NULL OR SUM(product_balances.quantity) = ?'} ", 0)
                .group('products.id') if balance.present?
    if barcode.present?
      items = items.left_joins(:product_feature_items)
      if barcode == "true"
        items = items.where("product_feature_items.barcode IS NOT ? AND product_feature_items.barcode !=''", nil)
      else
        items = items.where("product_feature_items.barcode IS ? OR product_feature_items.barcode =''", nil)
      end
    end
    items = items.left_joins(:product_location_balances)
                .having("#{desk == "true" ? 'SUM(product_location_balances.quantity) > ?' : 'SUM(product_location_balances.quantity) IS NULL OR SUM(product_location_balances.quantity) = ?'} ", 0)
                .group('products.id') if desk.present?
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
        .order(:n_name)
        .group(:id)
  }

  def all_categories
    categories = get_parent_category([category], category)
    categories.reverse

    if category.cross_id.present?
      cross_categories = get_parent_category([category.cross], category.cross)
      cross_categories.reverse
      categories = categories + cross_categories
    end

    categories
  end

  def get_parent_category(parents, category)
    if category.parent.present?
      parents << category.parent
      get_parent_category(parents, category.parent)
    else
      parents
    end
  end

  def check_filter_group_selected(ids)
    (ids & product_filter_groups.map(&:category_filter_group_id).to_a).any?
  end

  def full_name
    name_with_code
  end

  def name
    n = n_name
    n += ", #{brand.name}" if brand.present? && brand_id != 69
    n += ", #{n_model}" if n_model.present?
    n += ", #{n_package}" if n_package.present?
    n += ", #{n_material}" if n_material.present?
    n += ", #{n_advantage}" if n_advantage.present?
    n
  end

  def name_with_code
    n = "#{self.n_name}, #{self.code}"
    n += ", #{brand.name}" if brand.present? && brand_id != 69
    n
  end

  def cn_name
    c_name.presence || name
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

  def get_instruction(size_id, feature_id)
    size_instructions = self.product_size_instructions.by_size_feature(size_id, feature_id)
    if size_instructions.present?
      size_instruction = size_instructions.first
      ApplicationController.helpers.get_f(size_instruction.instruction)
    else
      ""
    end
  end

  def get_specification(spec_item_id)
    size_specifications = self.product_specifications.by_spec_item_id(spec_item_id)
    if size_specifications.present?
      size_specification = size_specifications.first
      size_specification.specification
    else
      ""
    end
  end

  def picture_url
    if picture.present?
      picture.url
    end
  end

  def product_discount
    percent = 0
    discounts = self.product_discounts.by_available
    if discounts.present?
      product_discount = discounts.last
      percent = product_discount.percent
    end

    percent
  end

  def price
    if product_feature_items.present?
      product_feature_item = product_feature_items.first
      product_feature_item.price
    else
      0
    end
  end

  def images_multi=(array = [])
    array.each do |f|
      product_images.create image: f
    end
  end

  def check_balance
    product_balances.count > 0
  end

  def balance
    ProductBalance.balance(id)
  end

  # private

  def valid_custom
    errors.add(:category_id, :blank) if category_id.present? && ProductCategory.search(category_id).count > 0
  end

  def valid_option_rels
    self.errors.add(:product_feature_option_rels, :too_short, count: 1) unless option_rels.present?
  end

  def valid_image_videos
    # Ганц сонголттой бол зураггүй байж болно
    any_img = true

    if product_feature_items.size != 1
      product_feature_items.each do |p_img|
        unless p_img.image.present? || p_img.same_item_id.present?
          p_img.errors.add(:image, :blank)
          any_img = false if any_img
        end
      end
    end

    self.errors.add(:product_feature_items, :blank) unless any_img
    self.errors.add(:product_photos, :blank) if photo_web && !product_photos.present?
  end

  def option_rel_ids
    feature_option_ids = option_rels.map(&:to_i)
    feature_options = ProductFeatureOption.by_ids(feature_option_ids)
    feature_types = Hash.new
    feature_options.each do |f_option|
      feature_types[f_option.product_feature.feature_type] = "f_type"
    end
    # Зөвхөн нэг талын хэмжээс сонгосон жн дан размер
    if feature_types.size == 1
      feature_option_ids << 12
    end

    feature_option_ids
  end

  def set_option_rels
    if option_rels.present?
      was_option_ids = product_feature_option_rels.map(&:feature_option_id).to_a
      feature_option_rels = option_rel_ids
      delete_ids = was_option_ids - feature_option_rels
      # Адил шинж чанар дээр агуулсан бол устгана
      if delete_ids.length > 0
        same_id_features = ProductFeatureItem.by_product_id(self.id)
                               .by_option_ids(delete_ids)
                               .same_id_not_nil
        same_id_features.each do |s_item|
          s_item.same_item = nil
          s_item.save
        end
      end
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
                  self.product_feature_items << ProductFeatureItem.new(option1_id: option_1, option2_id: option_2, p_6_8: is_own ? 5 : nil, p_9_: is_own ? 6 : nil)
                  added_feature_items[added_key] == "added"
                end
              end
            end
          }
        end
      end

    elsif product_feature_option_rels.count == 0
      #   Өнгө размер сонгоогүй бол солголтгүй бараа үүсгэнэ
      self.product_feature_option_rels << ProductFeatureOptionRel.new(feature_option: ProductFeatureOption.find(12))
    end
  end

  def set_valid_value
    if deliveries.present?
      self.delivery_type = deliveries.map(&:to_i)
    end
  end

  def set_instructions
    if instruction_id.present?
      self.product_size_instructions.destroy_all
      instruction_id.each_with_index do |id, index|
        val = instruction_val[index]
        if val.present? && val != ""
          self.product_size_instructions << ProductSizeInstruction.new(size_instruction_id: id.split('-')[0],
                                                                       product_feature_option_id: id.split('-')[1],
                                                                       instruction: val)
        end
      end
    end
  end

  def set_specifications
    if specification_id.present?
      self.product_specifications.destroy_all
      specification_id.each_with_index do |id, index|
        val = specification_val[index]
        if val.present? && val != ""
          self.product_specifications << ProductSpecification.new(spec_item_id: id, specification: val)
        end
      end
    end
  end

  def set_option_item_single
    if product_feature_items.count == 0 && self.product_feature_option_rels.count == 1
      product_feature_option = self.product_feature_option_rels.first
      ProductFeatureItem.create(tab_index: 1, product: self, option1_id: product_feature_option.feature_option_id, option2_id: product_feature_option.feature_option_id,
                                p_6_8: is_own ? 5 : nil, p_9_: is_own ? 6 : nil)
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

  def set_product_type
    self.p_type = 2 unless is_own
  end

  def resize_img
    if self.picture.present?
      img = self.picture
      ApplicationController.helpers.resize_image(img.path(:original))
      ApplicationController.helpers.resize_image(img.path(:tumb))
    end
  end

  def check_image_size
    if self.picture.present?
      img = self.picture
      if img.queued_for_write[:original].present?
        geo = Paperclip::Geometry.from_file(img.queued_for_write[:original].path)
        ratio = geo.width / geo.height
        if ratio.to_i != 1
          self.errors.add(:picture, " 1x1 хэмжээтэй байх ёстой")
        end
      end
    end
  end

  def sync_web(method)
    if !draft && is_web
      self.method_type = method
      url = "products"
      if method == 'delete'
        params = nil
        url += "/" + id.to_s
      else
        params = self.to_json(methods: [:method_type, :picture_url], except: [:draft, :c_name, :user_id, :p_type, :picture_updated_at, :picture_file_size, :picture_content_type, :picture_file_name,
                                                                              :deleted_at, :created_at, :updated_at, :sync_at],
                              include: {
                                  :product_feature_option_rels => {
                                      only: [:id, :product_id, :feature_option_id],
                                  },
                                  :product_feature_items => {
                                      only: [:id, :product_id, :option1_id, :option2_id, :price, :p_6_8, :p_9_, :c_balance, :same_item_id], :methods => [:image_url],
                                  }})
      end
      # Rails.logger.debug(params)
      response = ApplicationController.helpers.api_request(url, method, params)
      # Rails.logger.debug("response.body #{response.body}")
      # puts "response.body #{response.body}")
      if response.code.to_i == 201
        self.update_attributes(sync_at: Time.now, method_type: 'sync')
      end
    end
  end
end
