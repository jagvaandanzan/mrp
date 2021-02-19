class ProductFeatureItem < ApplicationRecord
  belongs_to :product
  belongs_to :option1, -> {with_deleted}, :class_name => "ProductFeatureOption"
  belongs_to :option2, -> {with_deleted}, :class_name => "ProductFeatureOption"
  belongs_to :same_item, :class_name => "ProductFeatureItem", optional: true

  has_many :product_sale_items, :class_name => "ProductSaleItem", :foreign_key => "feature_item_id", dependent: :destroy
  has_many :product_supply_features, :class_name => "ProductSupplyFeature", :foreign_key => "feature_item_id", dependent: :destroy
  has_many :product_sales, through: :product_sale_items
  has_many :salesman_travel, through: :product_sales
  has_many :product_warehouse_locs, :class_name => "ProductWarehouseLoc", :foreign_key => "feature_item_id", dependent: :destroy
  has_many :product_balances, :class_name => "ProductBalance", :foreign_key => "feature_item_id", dependent: :destroy
  has_many :product_income_balances, :class_name => "ProductIncomeBalance", :foreign_key => "feature_item_id", dependent: :destroy
  has_many :product_location_balances, dependent: :destroy

  accepts_nested_attributes_for :product_location_balances, allow_destroy: true

  before_save :set_default
  validate :check_image_size

  with_options :if => Proc.new {|m| m.barcode.present?} do
    validates_uniqueness_of :barcode
  end

  after_create -> {sync_web('post')}
  after_update -> {sync_web('update')}, unless: Proc.new {self.method_type == "sync"}
  after_destroy -> {sync_web('delete')}
  attr_accessor :method_type, :is_add, :is_update, :location_balances

  has_attached_file :image, :path => ":rails_root/public/product_feature_items/image/:id_partition/:style.:extension", styles: {original: "1200x1200>", tumb: "400x400>"}, :url => '/product_feature_items/image/:id_partition/:style.:extension'
  validates_attachment :image,
                       content_type: {content_type: ["image/jpeg", "image/x-png", "image/png"], message: :content_type}, size: {less_than: 4.megabytes}

  with_options :if => Proc.new {|m| m.is_add.present?} do
    validates :c_balance, numericality: {greater_than: 0, only_integer: true, message: :invalid}
  end

  with_options :unless => Proc.new {|m| m.tab_index.present? || m.is_add.present?} do
    # validates :barcode, presence: true, length: {maximum: 255}
    # validates_uniqueness_of :barcode
    validates :price, presence: true, :numericality => true
  end

  with_options :if => Proc.new {|m| (m.tab_index == 3 || m.is_add.present?) && !m.same_item.present?} do
    validates :image, presence: true
  end

  with_options :if => Proc.new {|m| m.is_add.present?} do
    validates :option1_id, :option2_id, :barcode, presence: true
    validate :product_locations_count_check
  end

  with_options :if => Proc.new {|m| m.is_update.present?} do
    before_validation :parse_location_balance
    validates :price, :barcode, :c_balance, presence: true
    validate :product_locations_count_check
  end

  attr_accessor :tab_index

  scope :by_option_ids, ->(option_ids) {
    where("option1_id IN (?)", option_ids)
        .or(where("option2_id IN (?)", option_ids))
  }

  scope :order_is_feature, ->() {
    joins(:option1)
        .joins(:option2)
        .order("product_feature_options.queue")
        .order("option2s_product_feature_items.queue")
  }

  scope :by_same_ids, ->(ids) {
    where("same_item_id IN (?)", ids)
  }

  scope :same_id_not_nil, ->() {
    where("same_item_id IS NOT ?", nil)
  }

  scope :by_product_id, ->(product_id) {
    where(product_id: product_id)
  }
  scope :search, ->(product_id) {
    if product_id.nil?
      []
    else
      where(product_id: product_id)
          .order_is_feature
      # SELECT `product_feature_items`.* FROM `product_feature_items` INNER JOIN `product_features` ON `product_features`.` id ` = ` product_feature_items `.` feature1_id ` AND ` product_features `.` deleted_at ` IS NULL INNER JOIN ` product_features ` ` feature2s_product_feature_items ` ON ` feature2s_product_feature_items `.` id ` = ` product_feature_items `.` feature2_id ` AND ` feature2s_product_feature_items `.` deleted_at ` IS NULL INNER JOIN ` product_feature_options ` ON ` product_feature_options `.` id ` = ` product_feature_items `.` option1_id ` AND ` product_feature_options `.` deleted_at ` IS NULL INNER JOIN ` product_feature_options ` ` option2s_product_feature_items ` ON ` option2s_product_feature_items `.` id ` = ` product_feature_items `.` option2_id ` AND ` option2s_product_feature_items `.` deleted_at ` IS NULL WHERE ` product_feature_items `.` product_id ` = 12 ORDER BY IF(product_features.queue<feature2s_product_feature_items.queue, product_features.queue, feature2s_product_feature_items.queue)
      # .order("IF(product_features.queue<feature2s_product_feature_items.queue, product_features.queue, feature2s_product_feature_items.queue)")
    end
  }

  scope :sale_available, ->(salesman_id, product_id) {
    joins(:salesman_travel)
        .where(product_id: product_id)
        .where("salesman_travels.salesman_id = ?", salesman_id)
        .where("product_sale_items.quantity - IFNULL(product_sale_items.bought_quantity, 0) - IFNULL(product_sale_items.back_quantity, 0) > ?", 0)
  }

  scope :sale_available_item_quantity, ->(salesman_id, feature_item_id) {
    joins(:salesman_travel)
        .where(id: feature_item_id)
        .where("salesman_travels.salesman_id = ?", salesman_id)
        .sum("product_sale_items.quantity - IFNULL(product_sale_items.bought_quantity, 0) - IFNULL(product_sale_items.back_quantity, 0)")
  }

  scope :by_travel_id, ->(travel_id) {
    select("product_sale_items.feature_item_id as feature_item_id, SUM(product_sale_items.quantity) as quantity")
        .joins(:salesman_travel)
        .where("salesman_travels.id = ?", travel_id)
        .group(:id)
  }

  def balance
    ProductBalance.balance(product_id, id)
  end

  def name
    if option1_id == option2_id
      option1.name.to_s
    elsif option1_id == 12
      option2.name.to_s
    elsif option2_id == 12
      option1.name.to_s
    else
      option1.name.to_s + " - " + option2.name.to_s
    end
  end

  def cn_name
    c_name.presence || name
  end

  def image_url
    if img.present?
      img.url
    end
  end

  def img
    if image.present?
      image
    elsif same_item.present?
      same_item.image
    end
  end

  def location_balance
    s = ""
    product_location_balances.each_with_index {|loc_bal, index|
      location = loc_bal.product_location
      if index > 0
        s += "#"
      end
      s += "x#{location.x}y#{location.y}z#{location.y}=#{loc_bal.quantity}"
    }
    s
  end

  private

  def set_default
    self.p_6_8 = price - ((price * p_6_8_p) / 100) if p_6_8_p.present? && !p_6_8.present?
    self.p_9_ = price - ((price * p_9_p) / 100) if p_9_p.present? && !p_9_.present?

    if is_add.present?
      was_option_ids = product.product_feature_option_rels.map(&:feature_option_id).to_a

      unless was_option_ids.include? option1_id
        ProductFeatureOptionRel.create(product_id: product_id, feature_option_id: option1_id)
      end
      unless was_option_ids.include? option2_id
        ProductFeatureOptionRel.create(product_id: product_id, feature_option_id: option2_id)
      end

      self.product_balances << ProductBalance.new(product: product,
                                                  quantity: c_balance)
    end
  end

  def parse_location_balance
    if location_balances.present? && c_balance > 0
      quantity = c_balance - balance
      if quantity != 0
        product_balances << ProductBalance.new(product: product,
                                               quantity: quantity)
      end

      lbs = location_balances.split('#')
      self.product_location_balances.destroy_all
      lbs.each do |lb|
        locs = lb.split('=')
        loc = locs[0].downcase
        if loc.length > 5
          q = locs[1].to_i
          if q > 0
            index_x = loc.index('x')
            index_y = loc.index('y')
            index_z = loc.index('z')
            if !index_x.nil? && !index_y.nil? && !index_z.nil?
              x = loc[(index_x + 1)..(index_y - 1)].to_i
              y = loc[(index_y + 1)..(index_z - 1)].to_i
              z = loc.from(index_z + 1).to_i

              product_locations = ProductLocation.by_xyz(x, y, z)
              product_location = if product_locations.present?
                                   product_locations.first
                                 else
                                   ProductLocation.create(x: x, y: y, z: z)
                                 end
              self.product_location_balances << ProductLocationBalance.new(product_location: product_location,
                                                                           quantity: q)
            else
              self.errors.add(:product_location_balances, "Агуулахын байршилийн формат буруу байна")
            end
          end
        end
      end
    end
  end

  def product_locations_count_check
    s = 0
    self.product_location_balances.each do |location|
      lq = location.quantity
      if lq.present?
        if lq < 0
          errors.add(:product_location_balances, :greater_than, count: 0)
          return
        end
        s += location.quantity
      end
    end
    if (self.c_balance || 0) < s
      errors.add(:product_location_balances, :over)
    elsif self.c_balance > s
      errors.add(:product_location_balances, :equal_to, count: self.c_balance)
    end
  end

  def resize_img
    img = self.image
    if img.present?
      path_orig = img.queued_for_write[:original]
      path_thumb = img.queued_for_write[:tumb]
      ApplicationController.helpers.resize_image(path_orig.path) if path_orig.present?
      ApplicationController.helpers.resize_image(path_thumb.path) if path_thumb.present?
    end
  end

  def check_image_size
    if self.image.present?
      img = self.image
      if img.queued_for_write[:original].present?
        geo = Paperclip::Geometry.from_file(img.queued_for_write[:original].path)
        ratio = geo.width / geo.height
        if ratio.to_i != 1
          self.errors.add(:image, " 1x1 хэмжээтэй байх ёстой")
        end
      end
    end
  end

  def sync_web(method)
    self.method_type = method
    url = "product/feature_item"

    if method == 'delete'
      params = nil
      url += "/" + id.to_s

      # product_feature_option_rels г устгах ёстой
      delete_ids = []
      items = product.product_feature_items
                  .by_product_id(product_id)
                  .by_option_ids([self.option1_id])
      delete_ids << self.option1_id unless items.present?
      items = product.product_feature_items
                  .by_product_id(product_id)
                  .by_option_ids([self.option2_id])
      delete_ids << self.option2_id unless items.present?

      product.product_feature_option_rels.by_feature_option_ids(delete_ids).destroy_all
    else

      params = self.to_json(only: [:id, :product_id, :option1_id, :option2_id, :price, :p_6_8, :p_9_, :c_balance, :same_item_id], :methods => [:method_type, :image_url])
    end

    ApplicationController.helpers.api_request(url, method, params)
  end

end
