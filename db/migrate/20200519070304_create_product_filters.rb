class CreateProductFilters < ActiveRecord::Migration[5.2]
  def change
    create_table :product_filters do |t|
      t.references :product, null: false, foreign_key: true
      t.references :product_filter_group, foreign_key: true
      t.references :category_filter, null: false, foreign_key: true

      t.timestamps
    end
  end
end
