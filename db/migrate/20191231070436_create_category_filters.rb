class CreateCategoryFilters < ActiveRecord::Migration[5.2]
  def change
    create_table :category_filters do |t|
      t.references :category_filter_group, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
