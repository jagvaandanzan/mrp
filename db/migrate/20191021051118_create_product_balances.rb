class CreateProductBalances < ActiveRecord::Migration[5.2]
  def change
    create_table :product_balances do |t|
      t.references :product, foreign_key: true
      t.references :feature_rel, foreign_key: {to_table: :product_feature_rels}
      t.references :income_item, foreign_key: {to_table: :product_income_items}
      t.references :sale_item, foreign_key: {to_table: :product_sale_items}
      t.references :user, foreign_key: true
      t.references :operator, foreign_key: true
      t.integer :quantity

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
