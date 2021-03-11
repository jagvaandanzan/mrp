class AddLangToLogistics < ActiveRecord::Migration[5.2]
  def change
    # add_column :logistics, :lang, :string, after: 'gender', default: 'mn'
    # add_column :shipping_ers, :order_type, :integer, after: 'description', default: 1
    # add_column :product_supply_order_items, :pin, :boolean, after: 'purchase_date', default: false
    add_column :product_supply_order_items, :ordered_at, :datetime, after: 'cost'
  end
end
