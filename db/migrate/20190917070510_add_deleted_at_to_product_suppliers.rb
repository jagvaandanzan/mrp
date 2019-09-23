class AddDeletedAtToProductSuppliers < ActiveRecord::Migration[5.2]
  def change
    add_column :product_suppliers, :deleted_at, :datetime
    add_index :product_suppliers, :deleted_at
  end
end
