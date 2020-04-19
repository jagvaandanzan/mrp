class AddCodeToProductSaleCalls < ActiveRecord::Migration[5.2]
  def change
    add_column :product_sale_calls, :code, :string, after: 'product_id'
  end
end
