class CreateTmpProducts < ActiveRecord::Migration[5.2]
  def change
    # create_table :tmp_products do |t|
    #   t.string :name
    #   t.string :feature
    #   t.string :barcode
    #   t.integer :balance
    #   t.integer :price
    #   t.integer :serial_id
    #   t.string :location
    #
    #   t.timestamps
    # end
    # add_column :product_feature_items, :init_bal, :integer, :after => "balance"
    # add_column :product_sale_items, :deleted_at, :datetime, :after => "back_quantity"
    change_column :salesman_returns, :barcode, :boolean, default: false
    rename_column :salesman_returns, :barcode, :is_check
  end
end
