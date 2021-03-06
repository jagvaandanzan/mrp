class ProductWarehouseLoc < ApplicationRecord
  belongs_to :salesman_travel
  belongs_to :product
  belongs_to :location, :class_name => "ProductLocation"
  belongs_to :feature_item, -> {with_deleted}, :class_name => "ProductFeatureItem"
  has_one :salesman, through: :salesman_travel
  has_one :salesman_travel_sign, through: :salesman_travel
  has_one :user, through: :salesman_travel_sign
  has_one :product_location_balance, :class_name => "ProductLocationBalance", :foreign_key => "warehouse_loc_id", dependent: :destroy

  before_create :set_location_balance
  attr_accessor :code
  validates :quantity, numericality: {greater_than: 0}

  scope :by_travel, ->(travel_id, id = nil) {
    items = select("products.n_name as name,
            products.code as code,
            product_warehouse_locs.*")
                .joins(:product)
                .joins(:location)
    items = items.where(salesman_travel_id: travel_id) if travel_id.present?
    items = items.where(id: id) if id.present?

    items.order("product_locations.x")
        .order("product_locations.y")
        .order("product_locations.z")
  }

  scope :by_load_at, ->(load) {
    where("load_at is#{load ? ' NOT' : ''} ?", nil)
  }

  scope :by_salesman_at, ->(salesman) {
    where("salesman_at is#{salesman ? ' NOT' : ''} ?", nil)
  }

  scope :by_travel, ->(travel_id) {
    where(salesman_travel_id: travel_id)
  }
  scope :by_feature_item_id, ->(feature_item_id) {
    where(feature_item_id: feature_item_id)
  }

  scope :date_by_load_at, ->(date) {
    select("salesman_travels.salesman_id, salesmen.name as salesman_name, SUM(quantity) as quantity")
        .joins(:salesman)
        .where("product_warehouse_locs.load_at IS NOT ?", nil)
        .where('? <= product_warehouse_locs.load_at AND product_warehouse_locs.load_at < ?', date, date + 1.day)
        .group("salesman_travels.salesman_id")
  }
  scope :salesman_with_date, ->(salesman_id, date) {
    select("product_warehouse_locs.*, users.name as user_sign")
        .joins(:user)
        .where("salesman_travels.salesman_id = ?", salesman_id)
        .where("product_warehouse_locs.load_at IS NOT ?", nil)
        .where('? <= product_warehouse_locs.load_at AND product_warehouse_locs.load_at < ?', date, date + 1.day)
  }

  def feature
    feature_item.name
  end

  def image
    feature_item.img
  end

  def barcode
    feature_item.barcode
  end

  def desk
    location.name
  end

  def name
    product.full_name
  end

  private

  def set_location_balance
    self.product_location_balance = ProductLocationBalance.create(product_location: location,
                                                                  product_feature_item: feature_item,
                                                                  travel: salesman_travel,
                                                                  quantity: -quantity)
  end

end
