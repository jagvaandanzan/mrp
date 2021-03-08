products = Product.sync_nil
puts "products: #{products.count}"
products.each do |product|
  puts "product: #{product.id}"
  product.sync_web('post')
end
p_ids = products.map(&:id).to_a
puts "#{p_ids}"

product_packages = ProductPackage.sync_by_p(p_ids)
puts "product_packages: #{product_packages.count}"
product_packages.each do |product_package|
  puts "product_package: #{product_package.id}"
  product_package.sync_web('post')
end

product_filter_groups = ProductFilterGroup.sync_by_p(p_ids)
puts "product_filter_groups: #{product_filter_groups.count}"
product_filter_groups.each do |product_filter_group|
  puts "product_filter_group: #{product_filter_group.id}"
  product_filter_group.sync_web('post')
end

product_filters = ProductFilter.sync_by_p(p_ids)
puts "product_filters: #{product_filters.count}"
product_filters.each do |product_filter|
  puts "product_filter: #{product_filter.id}"
  product_filter.sync_web('post')
end

product_images = ProductImage.sync_by_p(p_ids)
puts "product_images: #{product_images.count}"
product_images.each do |product_image|
  puts "product_image: #{product_image.id}"
  product_image.sync_web('post')
end

product_specifications = ProductSpecification.sync_by_p(p_ids)
puts "product_specifications: #{product_specifications.count}"
product_specifications.each do |product_specification|
  puts "product_specification: #{product_specification.id}"
  product_specification.sync_web('post')
end

product_videos = ProductVideo.sync_by_p(p_ids)
puts "product_videos: #{product_videos.count}"
product_videos.each do |product_video|
  puts "product_video: #{product_video.id}"
  product_video.sync_web('post')
end