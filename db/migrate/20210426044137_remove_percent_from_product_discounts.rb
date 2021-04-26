class RemovePercentFromProductDiscounts < ActiveRecord::Migration[5.2]
  def change
    add_column :product_discounts, :price, :integer, after: 'user_id'
    change_column :product_discounts, :percent, :float, :limit => 53
  end
end
