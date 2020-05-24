class CreateProductInstructions < ActiveRecord::Migration[5.2]
  def change
    create_table :product_instructions do |t|
      t.references :product, null: false, foreign_key: true
      t.integer :i_type
      t.text :description
      t.attachment :image
      t.attachment :video

      t.timestamps
    end
  end
end
