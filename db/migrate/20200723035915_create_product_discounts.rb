class CreateProductDiscounts < ActiveRecord::Migration[5.2]
  def change
    # create_table :product_discounts do |t|
    #   t.references :product, null: false, foreign_key: true
    #   t.references :user, null: false, foreign_key: true
    #   t.integer :percent
    #   t.datetime :start_date
    #   t.datetime :end_date
    #
    #   t.timestamps
    # end
    # add_column :customers, :code, :string, after: 'queue'
    # add_reference :shipping_er_items, :same_item, foreign_key: {to_table: :shipping_er_items}, after: 'cargo'
    # add_reference :shipping_ub_items, :same_item, foreign_key: {to_table: :shipping_ub_items}, after: 'cargo'
    # add_reference :product_categories, :cross, foreign_key: {to_table: :product_categories}, after: 'parent_id'
    # add_attachment :product_categories, :image, after: 'is_clothes'
    remove_reference :product_locations, :parent
    remove_column :product_locations, :name
    remove_column :product_locations, :code
    remove_column :product_income_items, :shelf
    add_column :product_locations, :queue, :integer, after: 'id'
    add_column :product_locations, :x, :integer, after: 'queue'
    add_column :product_locations, :y, :integer, after: 'x'
    add_column :product_locations, :z, :integer, after: 'y'
  end
end
