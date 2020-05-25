class CreateProductSizeInstructions < ActiveRecord::Migration[5.2]
  def change
    create_table :product_size_instructions do |t|
      t.references :product, null: false, foreign_key: true
      t.references :size_instruction, null: false, foreign_key: true
      t.float :instruction, limit: 53

      t.timestamps
    end

    remove_attachment :products, :size_img
  end
end
