class CreateShippingUbItems < ActiveRecord::Migration[5.2]
  def change
    # create_table :shipping_ub_items do |t|
    #   t.references :shipping_ub, null: false, foreign_key: true
    #   t.references :product_supply_feature, null: false, foreign_key: true
    #   t.references :product, null: false, foreign_key: true
    #   t.references :shipping_er_item, null: false, foreign_key: true
    #   t.integer :loaded
    #   t.integer :cargo
    #   t.integer :s_type
    #   t.float :cost
    #
    #   t.timestamps
    # end
    # add_column :product_incomes, :cargo_price, :integer, after: 'note'
    # remove_column :product_incomes, :note, :string
    #
    # add_reference :product_income_items, :shipping_ub_item, foreign_key: true, after: 'product_income_id'
    add_reference :product_income_items, :supply_feature, foreign_key: {to_table: :product_supply_features}, after: 'shipping_ub_id'
    remove_reference :product_income_items, :supply_order_item
    remove_reference :product_income_items, :product_supplier
    add_column :product_income_items, :cargo, :integer, after: 'quantity'
    add_column :product_income_items, :qr_printed, :integer, after: 'sum_price'
    remove_column :product_income_items, :sum_price, :float
    add_column :product_income_items, :problematic, :integer, after: 'sum_tug'
    remove_column :product_income_items, :sum_tug, :float
    add_column :product_income_items, :shelf, :integer, after: 'shuudan'
    remove_column :product_income_items, :shuudan, :float
    remove_column :product_income_items, :price, :float
    remove_column :product_income_items, :date, :datetime
    remove_column :product_income_items, :note, :string
    remove_column :product_income_items, :urgent_type, :integer
    remove_column :product_incomes, :sum_price, :float

  end
end
