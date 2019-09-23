class CreateProductIncomeFeatureRels < ActiveRecord::Migration[5.2]
  def change
    create_table :product_income_feature_rels do |t|
      t.references :income_item
      t.references :feature_option

      t.timestamps
    end
  end
end
