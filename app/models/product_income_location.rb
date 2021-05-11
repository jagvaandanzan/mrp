class ProductIncomeLocation < ApplicationRecord
  belongs_to :income_item, :class_name => "ProductIncomeItem"
  belongs_to :location, :class_name => "ProductLocation"
  has_one :product_location_balance, :class_name => "ProductLocationBalance", :foreign_key => "income_location_id", dependent: :destroy

  before_create :check_location
  before_create :set_location_balance
  validates :quantity, :x, :y, :z, presence: true

  attr_accessor :x, :y, :z

  private

  def check_location
    locs = ProductLocation.by_xyz(x, y, z)
    if locs.present?
      self.location = locs.first
    else
      self.location = ProductLocation.create(x: x, y: y, z: z)
    end
  end

  def set_location_balance
    if product_location_balance.present?
      self.product_location_balance.update(product_location: location,
                                           product_feature_item: income_item.feature_item,
                                           income_item: income_item,
                                           quantity: quantity)
    else
      self.product_location_balance = ProductLocationBalance.create(product_location: location,
                                                                    product_feature_item: income_item.feature_item,
                                                                    income_item: income_item,
                                                                    quantity: quantity)
    end
  end

end
