class CreateProductDiscounts < ActiveRecord::Migration[5.2]
  def change
    create_table :product_discounts do |t|
      t.references :product, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :percent
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps
    end
  end
end
