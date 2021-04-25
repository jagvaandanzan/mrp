Product.id_than(2122).each {|product|
  product.picture.reprocess! :cover, :tumb
  puts "product: #{product.id}"
}