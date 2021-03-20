class AddLangToLogistics < ActiveRecord::Migration[5.2]
  def change
    add_reference :product_sales, :parent, foreign_key: {to_table: :product_sales}, after: 'sale_call_id'
  end
end
