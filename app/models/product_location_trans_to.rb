class ProductLocationTransTo < ApplicationRecord
  belongs_to :trans_item, :class_name => "ProductLocationTransItem"
  belongs_to :location_transfer, :class_name => "ProductLocationTransfer"
  belongs_to :product_location
  belongs_to :product_feature_item

  has_one :product_location_balance, :class_name => "ProductLocationBalance", :foreign_key => "transfer_to_id", dependent: :destroy

  before_create :check_location
  after_create :set_location_balance

  attr_accessor :x, :y, :z

  private

  def check_location
    locs = ProductLocation.by_xyz(x, y, z)
    if locs.present?
      self.product_location = locs.first
    else
      self.product_location = ProductLocation.create(x: x, y: y, z: z)
    end
  end

  def set_location_balance
    self.product_location_balance = ProductLocationBalance.create(product_location: product_location,
                                                                  product_feature_item: product_feature_item,
                                                                  transfer_to: self,
                                                                  quantity: quantity)
    from_locations = ProductLocationBalance
                         .by_location_id(location_transfer.product_location_id)
                         .by_feature_item_id(product_feature_item_id)
    q = 0
    from_locations.each do |loc_bal|
      if quantity - q >= loc_bal.quantity
        q += loc_bal.quantity
        loc_bal.destroy
      else
        loc_bal.update_column(:quantity, loc_bal.quantity - quantity + q)
      end
    end

  end
end
