class CreateProductSaleExchanges < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :pin_code, :string, after: 'user_position_id'
  end
end
