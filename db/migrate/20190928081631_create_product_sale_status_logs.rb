class CreateProductSaleStatusLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :product_sale_status_logs do |t|
      t.references :product_sale
      t.references :operator
      t.references :status
      t.string :note

      t.timestamps
    end
  end
end
