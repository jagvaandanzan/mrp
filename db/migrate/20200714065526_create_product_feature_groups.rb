class CreateProductFeatureGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :product_feature_groups do |t|
      t.integer :queue
      t.string :name
      t.string :code
      t.datetime :deleted_at

      t.timestamps
    end

    add_reference :product_feature_options, :group, foreign_key: {to_table: :product_feature_groups}, after: 'id'
    add_column :product_feature_options, :code, :string, after: 'name'
  end

end
