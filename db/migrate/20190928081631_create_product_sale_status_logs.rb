class CreateProductSaleStatusLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :product_sale_status_logs do |t|
      t.references :product_sale, foreign_key: true
      t.references :operator, foreign_key: true
      t.references :status, foreign_key: {to_table: :product_sale_statuses}
      t.integer :log_type
      t.string :note

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
