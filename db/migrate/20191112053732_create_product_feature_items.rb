class CreateProductFeatureItems < ActiveRecord::Migration[5.2]
  def change
    create_table :product_feature_items do |t|
      t.references :product, foreign_key: true
      t.references :feature_rel, foreign_key: {to_table: :product_feature_rels}
      t.references :feature1, foreign_key: {to_table: :product_features}
      t.references :option1, foreign_key: {to_table: :product_feature_options}
      t.references  :feature2, foreign_key: {to_table: :product_features}
      t.references :option2, foreign_key: {to_table: :product_feature_options}

      t.timestamps
    end
  end
end
