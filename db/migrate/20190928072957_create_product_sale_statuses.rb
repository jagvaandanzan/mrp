class CreateProductSaleStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :product_sale_statuses do |t|
      t.string :name
      t.string :alias
      t.references :parent
      t.timestamps
    end

    add_column :product_sale_statuses, :deleted_at, :datetime
    add_index :product_sale_statuses, :deleted_at
  end
end
