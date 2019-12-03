class AddToSeeToProductSaleItems < ActiveRecord::Migration[5.2]
  def change
    add_column :product_sale_items, :to_see, :boolean, default: 0, after: 'sum_price'

    remove_column :products, :sale_price, :float
    remove_column :products, :discount_price, :float
  end
end
