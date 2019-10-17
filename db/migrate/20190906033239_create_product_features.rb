class CreateProductFeatures < ActiveRecord::Migration[5.2]
  def change
    create_table :product_features do |t|
      t.string :name
      t.string :description

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
