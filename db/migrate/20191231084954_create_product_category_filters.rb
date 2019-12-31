class CreateProductCategoryFilters < ActiveRecord::Migration[5.2]
  def change
    create_table :product_category_filters do |t|
      t.references :product_category, foreign_key: true
      t.references :category_filter_group, foreign_key: true

      t.timestamps
    end
  end
end
