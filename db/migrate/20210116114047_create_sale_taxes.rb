class CreateSaleTaxes < ActiveRecord::Migration[5.2]
  def change
    # add_column :shipping_er_products, :cost, :float, after: 'cargo'
    # add_column :shipping_ub_boxes, :cost, :float, after: 'shipping_ub_id'
    add_column :shipping_ub_products, :cargo, :integer, after: 'cost'
  end
end
