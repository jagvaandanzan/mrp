class CreateProductSamples < ActiveRecord::Migration[5.2]
  def change
    create_table :product_samples do |t|
      t.string :code
      t.datetime :ordered_date
      t.references :supplier, foreign_key: {to_table: :product_suppliers}
      t.integer :payment
      t.integer :exchange
      t.float :exchange_value
      t.references :user, null: false, foreign_key: true
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
