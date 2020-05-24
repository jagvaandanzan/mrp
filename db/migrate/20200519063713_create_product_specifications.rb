class CreateProductSpecifications < ActiveRecord::Migration[5.2]
  def change
    create_table :product_specifications do |t|
      t.references :product, null: false, foreign_key: true
      t.references :technical, null: false, foreign_key: {to_table: :technical_specifications}
      t.string :specification

      t.timestamps
    end
  end
end
