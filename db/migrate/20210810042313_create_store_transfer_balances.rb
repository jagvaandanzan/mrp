class CreateStoreTransferBalances < ActiveRecord::Migration[5.2]
  def change
    create_table :store_transfer_balances do |t|
      t.references :product, null: false, foreign_key: true
      t.references :feature_item, null: false, foreign_key: {to_table: :product_feature_items}
      t.references :user, foreign_key: true
      t.references :storeroom, null: false, foreign_key: true
      t.references :transfer_item, null: false, foreign_key: {to_table: :store_transfer_items}
      t.integer :quantity

      t.timestamps
    end
  end
end
