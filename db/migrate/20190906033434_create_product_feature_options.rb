class CreateProductFeatureOptions < ActiveRecord::Migration[5.2]
  def change
    create_table :product_feature_options do |t|
      t.string :name
      t.references :product_feature, foreign_key: true

      t.timestamps
    end
  end
end
