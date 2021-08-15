class CreateDirectSales < ActiveRecord::Migration[5.2]
  def change
    # create_table :direct_sale_types do |t|
    #   t.integer :code
    #   t.string :name
    #
    #   t.timestamps
    # end
    #
    # create_table :purchasers do |t|
    #   t.integer :code
    #   t.string :name
    #
    #   t.timestamps
    # end
    #
    # create_table :direct_sales do |t|
    #   t.datetime :date
    #   t.references :sale_type, null: false, foreign_key: {to_table: :direct_sale_types}
    #   t.references :user, foreign_key: true
    #   t.references :purchaser, foreign_key: true
    #   t.integer :phone
    #   t.integer :price_type
    #   t.integer :discount
    #   t.integer :cost
    #   t.string :cost_note
    #   t.text :value
    #   t.boolean :tax, default: false
    #
    #   t.references :owner, null: false, foreign_key: {to_table: :users}
    #
    #   t.timestamps
    # end
    #
    # create_table :direct_sale_items do |t|
    #   t.references :direct_sale, null: false, foreign_key: true
    #   t.references :product, null: false, foreign_key: true
    #   t.references :feature_item, null: false, foreign_key: {to_table: :product_feature_items}
    #   t.references :product_location, foreign_key: true
    #   t.integer :quantity
    #   t.float :price
    #   t.float :sum_price
    #   t.integer :discount
    #   t.float :pay_price
    #   t.timestamps
    # end
    #
    # add_reference :product_balances, :direct_sale_item, foreign_key: true, after: 'transfer_item_id'
    # add_reference :bonus_balances, :direct_sale_item, foreign_key: true, after: 'product_sale_item_id'

    add_reference :sale_taxes, :direct_sale, foreign_key: true, after: 'product_sale_id'
    change_column_null :sale_taxes, :product_sale_id, true
    add_reference :direct_sale_items, :product_location, foreign_key: true, after: 'feature_item_id'
    add_reference :product_location_balances, :direct_sale_item, foreign_key: true, after: 'warehouse_loc_id'
    add_reference :product_location_balances, :store_transfer_item, foreign_key: true, after: 'direct_sale_item_id'
    add_reference :storerooms, :product_location, foreign_key: true, after: 'name'
  end
end
