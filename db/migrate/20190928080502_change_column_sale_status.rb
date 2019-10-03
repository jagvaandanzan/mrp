class ChangeColumnSaleStatus < ActiveRecord::Migration[5.2]
  def change
    add_column :product_sale_statuses, :note, :string
    add_column :product_sale_statuses, :queue, :integer
  end
end
