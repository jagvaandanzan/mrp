class CreateSalesmanReturns < ActiveRecord::Migration[5.2]
  def change
    create_table :salesman_returns do |t|
      t.references :sign, foreign_key: {to_table: :salesman_return_signs}
      t.references :salesman, null: false, foreign_key: true
      t.references :user,  foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.references :feature_item, null: false, foreign_key: {to_table: :product_feature_items}
      t.references :sale_item, null: false, foreign_key: {to_table: :product_sale_items}
      t.integer :quantity
      t.boolean :barcode

      t.timestamps
    end
    add_reference :notifications, :return_sign, foreign_key: {to_table: :salesman_return_signs}, after: 'salesman_travel_id'
  end
end
