class AddCodeToProductSaleCalls < ActiveRecord::Migration[5.2]
  def change
    change_column :fb_comment_actions, :reply_txt, :text
    add_column :product_sale_calls, :message, :text, after: 'quantity'
  end
end
