class AddPerPriceToShippingErProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :shipping_er_products, :per_price, :float, :limit => 53, after: 'cost'
    remove_column :shipping_ers, :per_price
  end
end
