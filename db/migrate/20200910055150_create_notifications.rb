class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    # create_table :product_call_items do |t|
    #   t.references :product_sale_call, null: false, foreign_key: true
    #   t.references :product, null: false, foreign_key: true
    #   t.references :feature_item, foreign_key: {to_table: :product_feature_items}
    #   t.integer :quantity
    #   t.integer :price
    #   t.integer :sum_price
    #   t.timestamps
    # end

    # add_column :product_sale_calls, :status, :integer, after: 'id'
    # add_column :product_sale_calls, :deleted_at, :datetime, after: 'operator_id'
    # add_column :product_sale_calls, :sum_price, :integer, after: 'product_id'
    #
    # remove_reference :product_sale_calls, :product
    # remove_column :product_sale_calls, :quantity
    remove_reference :locations, :user
    add_column :locations, :distance, :integer, after: 'longitude'

  end
end
