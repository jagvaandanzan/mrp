class CreateProductSampleImages < ActiveRecord::Migration[5.2]
  def change
    create_table :product_sample_images do |t|
      t.references :product_sample, null: false, foreign_key: true
      t.attachment :image

      t.timestamps
    end
  end
end
