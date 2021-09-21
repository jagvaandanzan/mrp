ProductBalance.joins(:product_sale)
    .where("product_balances.created_at < '2021-09-20 00:00:00'")
    .where("product_sale_items.back_quantity IS NULL AND product_sale_items.bought_quantity IS NULL AND")
    .each do |bal|
    puts "#{bal.id} ==> #{bal.quantity} ==> #{bal.sale_item_id} ==> #{bal.feature_item_id}"

end
