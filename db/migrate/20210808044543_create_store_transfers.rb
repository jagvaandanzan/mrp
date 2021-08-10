class CreateStoreTransfers < ActiveRecord::Migration[5.2]
  def change
    create_table :store_transfers do |t|
      t.datetime :date
      t.references :store_from, foreign_key: {to_table: :storerooms}
      t.references :store_to, foreign_key: {to_table: :storerooms}
      t.references :user, foreign_key: true
      t.text :value

      t.timestamps
    end

    create_table :store_transfer_items do |t|
      t.references :store_transfer, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.references :feature_item, null: false, foreign_key: {to_table: :product_feature_items}
      t.references :product_location, foreign_key: true
      t.integer :quantity
      t.float :price
      t.float :sum_price
      t.text :description

      t.timestamps
    end
    add_reference :product_balances, :transfer_item, foreign_key: {to_table: :store_transfer_items}, after: 'salesman_return_id'
  end
end
