class AddColumnsToProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :main_code, :string

  end
end
