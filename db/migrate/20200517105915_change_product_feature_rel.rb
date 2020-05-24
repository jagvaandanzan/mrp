class ChangeProductFeatureRel < ActiveRecord::Migration[5.2]
  def change
    remove_column :product_warehouse_locs, :feature_rel_id, :references
    remove_column :product_income_items, :feature_rel_id, :references
    remove_column :product_sale_items, :feature_rel_id, :references
    remove_column :product_sale_directs, :feature_rel_id, :references
    remove_column :product_feature_items, :feature_rel_id, :references
    remove_column :product_feature_items, :feature1_id, :references
    remove_column :product_feature_items, :feature2_id, :references
    add_column :product_features, :feature_type, :integer, after: 'id'
    add_column :products, :delivery_type, :integer, after: 'is_own'
    add_attachment :products, :size_img, after: 'delivery_type'
    add_column :product_feature_items, :price, :integer, after: 'option2_id'
    add_column :product_feature_items, :p_6_8, :integer, after: 'price'
    add_column :product_feature_items, :p_9_, :integer, after: 'p_6_8'
    add_column :product_feature_items, :c_balance, :integer, after: 'p_9_'
    add_column :products, :search_key, :text, after: 'delivery_type'
    add_column :products, :description, :text, :limit => 4294967295, after: 'search_key'
    add_column :products, :expiry_date, :datetime, after: 'description'
    add_column :products, :photo_web, :boolean, after: 'expiry_date', default: false
    add_column :products, :product_size, :string, after: 'photo_web'
    add_column :products, :package_size, :string, after: 'product_size'
    add_column :products, :weight, :string, after: 'package_size'
    add_column :products, :gift_wrap, :integer, after: 'weight'
  end
end
