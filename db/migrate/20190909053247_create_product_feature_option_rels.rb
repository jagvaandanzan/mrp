class CreateProductFeatureOptionRels < ActiveRecord::Migration[5.2]
  def change
    create_table :product_feature_option_rels do |t|
      t.references :product
      t.references :feature_option
      t.integer :feature_id

      t.timestamps
    end
  end
end
