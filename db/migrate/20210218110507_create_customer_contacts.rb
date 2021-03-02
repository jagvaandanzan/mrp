class CreateCustomerContacts < ActiveRecord::Migration[5.2]
  def change
    add_column :product_sale_items, :p_discount, :integer, after: 'price'
    add_column :product_sale_items, :discount, :integer, after: 'p_discount'
    add_column :products, :balance, :integer, after: 'category_id'
    rename_column :product_feature_items, :c_balance, :balance
  end
end
