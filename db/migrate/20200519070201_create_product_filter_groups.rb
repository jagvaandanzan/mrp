class CreateProductFilterGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :product_filter_groups do |t|
      t.references :product, null: false, foreign_key: true
      t.references :category_filter_group, null: false, foreign_key: true

      t.timestamps
    end
  end
end
