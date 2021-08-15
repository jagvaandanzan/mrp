class CreateStorerooms < ActiveRecord::Migration[5.2]
  def change
    create_table :storerooms do |t|
      t.integer :code
      t.string :name
      t.references :product_location, foreign_key: true

      t.datetime :deleted_at
      t.timestamps
    end

    add_column :product_feature_items, :deleted_at, :datetime, after: 'real_img'
  end
end
