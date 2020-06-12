class CreateProductPackages < ActiveRecord::Migration[5.2]
  def change
    create_table :product_packages do |t|
      t.references :product, null: false, foreign_key: true
      t.string :product_size
      t.integer :package_unit
      t.float :length
      t.float :width
      t.float :height
      t.integer :weight_unit
      t.float :weight
      t.integer :gift_wrap

      t.timestamps
    end
  end
end
