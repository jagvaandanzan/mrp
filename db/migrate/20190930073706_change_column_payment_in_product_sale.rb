class ChangeColumnPaymentInProductSale < ActiveRecord::Migration[5.2]
  def change
    change_column :product_sales, :payment_account, :float, limit:53
    change_column :product_sales, :payment_delivery, :float, limit:53
  end
end
