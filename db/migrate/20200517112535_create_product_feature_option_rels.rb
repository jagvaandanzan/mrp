class CreateProductFeatureOptionRels < ActiveRecord::Migration[5.2]
  def change
    create_table :product_feature_option_rels do |t|
      t.references :product, null: false, foreign_key: true
      t.references :feature_option, foreign_key: {to_table: :product_feature_options}

      t.timestamps
    end
  end
end
