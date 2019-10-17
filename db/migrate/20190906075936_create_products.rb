class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.references :category, foreign_key: {to_table: :product_categories}
      t.string :name
      t.string :code # tsaad taliin code
      t.string :main_code # uursdiin dotood code
      t.string :barcode # baraanii jinhene bar_code
      t.string :detail
      t.integer :measure # hemjih negj
      t.integer :ptype # zahialga, deej, damjuulah
      t.float :sale_price, limit: 53
      t.float :discount_price, limit: 53

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
