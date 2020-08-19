class ProductFeatureItem < ApplicationRecord
  belongs_to :product
  belongs_to :option1, :class_name => "ProductFeatureOption"
  belongs_to :option2, :class_name => "ProductFeatureOption"
  belongs_to :same_item, :class_name => "ProductFeatureItem", optional: true

  has_many :product_sale_items, :class_name => "ProductSaleItem", :foreign_key => "feature_item_id", dependent: :destroy
  has_many :product_supply_features, :class_name => "ProductSupplyFeature", :foreign_key => "feature_item_id", dependent: :destroy
  has_many :product_sales, through: :product_sale_items
  has_many :salesman_travel, through: :product_sales

  after_create -> {sync_web('post')}
  after_update -> {sync_web('update')}, unless: Proc.new {self.method_type == "sync"}
  after_destroy -> {sync_web('delete')}
  attr_accessor :method_type

  has_attached_file :image, :path => ":rails_root/public/product_feature_items/image/:id_partition/:style.:extension", styles: {original: "1200x1200>", tumb: "400x400>"}, :url => '/product_feature_items/image/:id_partition/:style.:extension'
  validates_attachment :image,
                       content_type: {content_type: ["image/jpeg", "image/x-png", "image/png"], message: :content_type}, size: {less_than: 4.megabytes}

  with_options :if => Proc.new {|m| m.product.is_customer?} do
    validates :c_balance, numericality: {greater_than: 0, only_integer: true, message: :invalid}
  end

  with_options :unless => Proc.new {|m| m.tab_index.present?} do
    validates :price, presence: true, :numericality => true
  end

  with_options :if => Proc.new {|m| m.tab_index == 3} do
    validates :feature_item_id, presence: true
    before_validation :check_same_id
  end

  with_options :if => Proc.new {|m| m.tab_index == 3 && !m.same_item.present?} do
    validates :image, presence: true
  end

  attr_accessor :tab_index

  scope :by_option_ids, ->(option_ids) {
    where("option1_id IN (?)", option_ids)
        .or(where("option2_id IN (?)", option_ids))
  }

  scope :order_is_feature, ->() {
    joins(:option1)
        .order("product_feature_options.queue")
  }


  scope :search, ->(product_id) {
    if product_id.nil?
      []
    else
      where(product_id: product_id)
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

  private

  def check_same_id
    if same_item.present? && id == same_item_id
      self.same_item = nil
    end
  end

  def sync_web(method)
    self.method_type = method
    url = "product/feature_item"

    if method == 'delete'
      params = nil
      url += "/" + id.to_s
    else

      params = self.to_json(only: [:id, :product_id, :option1_id, :option2_id, :price, :p_6_8, :p_9_, :c_balance, :same_item_id], :methods => [:method_type, :image_url])
    end

    ApplicationController.helpers.api_request(url, method, params)
  end
end
