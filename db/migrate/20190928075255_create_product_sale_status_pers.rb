class CreateProductSaleStatusPers < ActiveRecord::Migration[5.2]
  def change
    create_table :product_sale_status_pers do |t|
      t.integer :user_type
      t.references :status

      t.timestamps
    end
  end
end
