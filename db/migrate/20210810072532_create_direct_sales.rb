class CreateDirectSales < ActiveRecord::Migration[5.2]
  def change
    create_table :direct_sale_types do |t|
      t.integer :code
      t.string :name

      t.timestamps
    end

    create_table :purchasers do |t|
      t.integer :code
      t.string :name

      t.timestamps
    end

    create_table :direct_sales do |t|
      t.datetime :date
      t.references :sale_type, null: false, foreign_key: {to_table: :direct_sale_types}
      t.references :user, foreign_key: true
      t.references :purchaser, foreign_key: true
      t.integer :phone
      t.integer :price_type
      t.integer :discount
      t.integer :cost
      t.string :cost_note
      t.text :value
      t.boolean :tax, default: false

      t.references :owner, null: false, foreign_key: {to_table: :users}

      t.timestamps
    end

    create_table :direct_sale_items do |t|
      t.references :direct_sale, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.references :feature_item, null: false, foreign_key: {to_table: :product_feature_items}
      t.integer :quantity
      t.float :price
      t.float :sum_price
      t.integer :discount
      t.float :pay_price
      t.timestamps
    end

    add_reference :product_balances, :direct_sale_item, foreign_key: true, after: 'transfer_item_id'
    add_reference :bonus_balances, :direct_sale_item, foreign_key: true, after: 'product_sale_item_id'

  end
end
