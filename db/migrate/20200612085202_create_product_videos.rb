class CreateProductVideos < ActiveRecord::Migration[5.2]
  def change
    create_table :product_videos do |t|
      t.references :product, foreign_key: true
      t.attachment :video

      t.timestamps
    end
  end
end
