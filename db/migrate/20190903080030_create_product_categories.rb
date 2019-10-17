  class CreateProductCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :product_categories do |t|
      t.string :name
      t.string :code
      t.references :parent, foreign_key: { to_table: :product_categories }

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
