class AddQueueToFbCommentActions < ActiveRecord::Migration[5.2]
  def change
    change_column :product_sale_calls, :phone, :integer
  end
end
