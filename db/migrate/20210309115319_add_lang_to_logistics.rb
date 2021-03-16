class AddLangToLogistics < ActiveRecord::Migration[5.2]
  def change
    # change_column :shipping_ub_boxes, :is_box, :integer
    # rename_column :shipping_ub_boxes, :is_box, :box_type
    #
    # create_table :shipping_ub_samples do |t|
    #   t.references :shipping_ub, null: false, foreign_key: true
    #   t.string :number
    #   t.float :cost
    #   t.datetime :received_at
    #
    #   t.timestamps
    # end
    # change_column_null :product_income_products, :shipping_ub_product_id, true
    # add_reference :product_income_products, :shipping_ub_sample, foreign_key: true, after: 'shipping_ub_product_id'
    # add_reference :product_income_products, :product_supply_order, foreign_key: true, after: 'shipping_ub_sample_id'
    add_column :product_income_items, :is_match, :boolean, after: 'quantity', default: true

    create_table :product_income_logs do |t|
      t.references :product_income_item, null: false, foreign_key: true
      t.references :feature_item_was, foreign_key: {to_table: :product_feature_items}
      t.references :feature_item, foreign_key: {to_table: :product_feature_items}
      t.integer :quantity_was
      t.integer :quantity
      t.references :owner, foreign_key: {to_table: :users}
      t.references :user, foreign_key: true
      t.text :description

      t.timestamps
    end
  end
end
