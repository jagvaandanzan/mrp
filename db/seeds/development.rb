q = 0
i = 0
ProductSaleItem.where("'2021-09-21 00:00:00' <= created_at AND created_at < '2021-09-21 00:21:00' AND deleted_at IS NULL AND back_quantity IS NULL").each do |item|
  q += item.quantity
  i += 1
  puts "#{item.id} == #{item.quantity} = #{item.created_at}"

  # ProductBalance.create(product_id: item.product_id, feature_item_id: item.feature_item_id, quantity: -item.quantity, sale_item: item)
end

puts "#{q}"
puts "#{i}"
