class CreateProductSaleStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :product_sale_statuses do |t|
      t.integer :queue
      t.references :parent, foreign_key: {to_table: :product_sale_statuses}
      t.string :name
      t.string :alias
      t.string :user_type

      t.datetime :deleted_at
      t.timestamps
    end

  end
end
