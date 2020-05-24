class AddBrandToProducts < ActiveRecord::Migration[5.2]
  def change
    add_reference :products, :brand, foreign_key: true, after: 'code'
    add_reference :products, :manufacturer, foreign_key: true, after: 'brand_id'
  end
end
