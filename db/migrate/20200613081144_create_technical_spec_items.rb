class CreateTechnicalSpecItems < ActiveRecord::Migration[5.2]
  def change
    create_table :technical_spec_items do |t|
      t.references :technical_specification, null: false, foreign_key: true
      t.string :specification
      t.datetime :deleted_at

      t.timestamps
    end

    rename_column :technical_specifications, :specification, :specification_gr
    add_reference :products, :technical_specification, foreign_key: true, after: 'description'
  end
end
