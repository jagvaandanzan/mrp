class RemoveLogStatAttr < ActiveRecord::Migration[5.2]
  def change
    add_reference :product_sale_status_logs, :user, foreign_key: true, after: 'id'
  end
end
