class RemoveMainCodeFromProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :product_names do |t|
      t.references :product, null: false, foreign_key: true
      t.string :name
      t.integer :n_type

    end
    remove_column :products, :main_code, :string
    remove_column :products, :barcode, :string
    add_column :products, :is_own, :integer, after: 'measure', default: true
    remove_column :products, :measure, :integer
    remove_column :products, :ptype, :integer
    remove_column :products, :detail, :string
    change_column :products, :name, :text
  end
end
