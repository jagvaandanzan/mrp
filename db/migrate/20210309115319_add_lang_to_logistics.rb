class AddLangToLogistics < ActiveRecord::Migration[5.2]
  def change
    change_column :shipping_ub_boxes, :is_box, :integer
    rename_column :shipping_ub_boxes, :is_box, :box_type

    create_table :shipping_ub_samples do |t|
      t.references :shipping_ub, null: false, foreign_key: true
      t.string :number
      t.float :cost
      t.datetime :received_at

      t.timestamps
    end
    change_column_null :product_income_products, :shipping_ub_product_id, true
    add_reference :product_income_products, :shipping_ub_sample, foreign_key: true, after: 'shipping_ub_product_id'
    add_reference :product_income_products, :product_supply_order, foreign_key: true, after: 'shipping_ub_sample_id'
  end
end
