class CreateProductPhotos < ActiveRecord::Migration[5.2]
  def change
    create_table :product_photos do |t|
      t.references :product, null: false, foreign_key: true
      t.attachment :photo

      t.timestamps
    end
  end
end
