class CreateProductNames < ActiveRecord::Migration[5.2]
  def change
    create_table :product_names do |t|
      t.references :product, null: false, foreign_key: true
      t.string :name
      t.integer :n_type

      t.timestamps
    end
  end
end
