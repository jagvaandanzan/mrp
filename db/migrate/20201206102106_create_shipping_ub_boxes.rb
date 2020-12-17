class CreateShippingUbBoxes < ActiveRecord::Migration[5.2]
  def change
    create_table :shipping_ub_boxes do |t|
      t.references :shipping_ub, null: false, foreign_key: true

      t.timestamps
    end

    add_column :shipping_ubs, :s_type, :integer, after: 'date'
    drop_table :shipping_er_items
    drop_table :shipping_ub_items
  end
end
