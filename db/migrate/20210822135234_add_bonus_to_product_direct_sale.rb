class AddBonusToProductDirectSale < ActiveRecord::Migration[5.2]
  def change
    add_reference :bonus_balances, :product_sale_direct, foreign_key: true, after: 'direct_sale_item_id'

  end
end
