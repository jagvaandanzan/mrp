class CreateSaleTaxes < ActiveRecord::Migration[5.2]
  def change
    add_column :shipping_er_products, :cost, :float, after: 'cargo'
    add_column :shipping_ub_boxes, :cost, :float, after: 'shipping_ub_id'
    remove_column :shipping_ub_products, :cargo, :integer
    change_column :shipping_ub_products, :cost, :float
    remove_reference :product_income_items, :income_product
    add_reference :product_income_items, :product_income_product, after: 'product_income_id'
  end
end
