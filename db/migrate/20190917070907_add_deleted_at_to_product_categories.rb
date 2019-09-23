class AddDeletedAtToProductCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :product_categories, :deleted_at, :datetime
    add_index :product_categories, :deleted_at
  end
end
