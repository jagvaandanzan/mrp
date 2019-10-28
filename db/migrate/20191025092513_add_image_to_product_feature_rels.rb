class AddImageToProductFeatureRels < ActiveRecord::Migration[5.2]
  def change
    add_attachment :product_feature_rels, :image, after: 'barcode'
  end
end
