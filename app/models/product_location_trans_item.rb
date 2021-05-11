class ProductLocationTransItem < ApplicationRecord
  belongs_to :location_transfer, :class_name => "ProductLocationTransfer"
  belongs_to :product
  belongs_to :product_feature_item

  has_many :product_location_trans_tos, :class_name => "ProductLocationTransTo", :foreign_key => "trans_item_id"

  def transferred
    product_location_trans_tos.sum(:quantity)
  end

  def desk
    balances = product_feature_item.product_location_balances
                   .select("product_location_id, SUM(product_location_balances.quantity) as quantity")
                   .group(:product_location_id)
    s = ""
    balances.each_with_index do |b, index|
      if index > 0
        s += ", "
      end

      loc = ProductLocation.find(b['product_location_id'])
      s += "#{loc.name} - #{b['quantity']}ш"
    end
    s
  end

end
