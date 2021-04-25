Product.all.each do |product|
  items = product.product_feature_items
  options = (items.map(&:option1_id) + items.map(&:option2_id)).uniq
  rels = product.product_feature_option_rels.map(&:feature_option_id)
  a = (options - rels)
  b = (rels - options)

  if a.blank? && b.blank?
    puts "product: #{product.id} = OK"
  else
    unless b.blank?
      product.product_feature_option_rels.by_feature_option_ids(b).destroy_all
    end
    unless a.blank?
      a.each do |f|
        ProductFeatureOptionRel.create(product: product, feature_option_id: f)
      end
    end
    puts "product: #{product.id}, del:#{b}, insert: #{a}"
  end
end