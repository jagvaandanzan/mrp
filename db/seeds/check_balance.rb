products = Product.all
products.each(&:calc_balance)