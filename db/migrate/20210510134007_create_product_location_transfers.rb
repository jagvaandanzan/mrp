class CreateProductLocationTransfers < ActiveRecord::Migration[5.2]
  def change
    create_table :product_location_transfers do |t|
      t.references :user, foreign_key: true
      t.references :product_location, foreign_key: true

      t.timestamps
    end

    create_table :product_location_trans_items do |t|
      t.references :location_transfer, foreign_key: {to_table: :product_location_transfers}
      t.references :product, foreign_key: true
      t.references :product_feature_item, foreign_key: true
      t.integer :quantity

      t.timestamps
    end

    create_table :product_location_trans_tos do |t|
      t.references :trans_item, foreign_key: {to_table: :product_location_trans_items}
      t.references :location_transfer, foreign_key: {to_table: :product_location_transfers}
      t.references :product_location, foreign_key: true
      t.references :product_feature_item, foreign_key: true
      t.integer :quantity

      t.timestamps
    end
    add_reference :product_location_balances, :transfer_to, foreign_key: {to_table: :product_location_trans_tos}, after: 'income_location_id'
  end
end
