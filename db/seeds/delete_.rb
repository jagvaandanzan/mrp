# operators/product_sales_controller.rb
def delete_item
  status = true
  message = ""
  sale_item = ProductSaleItem.find(params[:id])
  if sale_item.destroy
    ProductSaleLog.create(operator: current_operator,
                          product_sale_id: sale_item.product_sale_id,
                          sale_item: sale_item,
                          o_product_id: sale_item.product_id,
                          o_feature_item_id: sale_item.feature_item_id,
                          o_quantity: sale_item.quantity,
                          o_to_see: sale_item.to_see,
                          o_p_discount: sale_item.p_discount,
                          o_discount: sale_item.discount)
    product = sale_item.product
    product.update_column(:balance, product.balance_sum)

    product_sale = sale_item.product_sale
    feature_item = sale_item.feature_item
    feature_item.update_column(:balance, feature_item.balance_sum)
    warehouse_locs = ProductWarehouseLoc.by_travel(product_sale.salesman_travel_id)
                         .by_feature_item_id(feature_item.id)
    q = sale_item.quantity
    if warehouse_locs.present?
      warehouse_locs.each do |loc|
        if q > 0
          if loc.quantity <= q
            loc.destroy
          else
            loc.update_column(:quantity, loc.quantity - q)
          end
          q -= loc.quantity
        else
          break
        end
      end
    end

    # Нийлбэр дүнг дахин бодох
    product_sale.update_sum_price
  else
    status = false
    message = sale_item.errors.full_messages
  end
  render json: {status: status, message: message}
end

def update_item
  status = true
  message = ""
  sale_item = if params[:id].to_i > 0
                ProductSaleItem.find(params[:id])
              else
                feature_item = ProductFeatureItem.find(params[:feature_item_id])
                ProductSaleItem.new(product_sale_id: params[:sale_id],
                                    price: feature_item.price.presence || 0)
              end
  feature_item_id = sale_item.feature_item_id
  product_id = sale_item.product_id
  log = ProductSaleLog.new(operator: current_operator,
                           product_sale_id: sale_item.product_sale_id,
                           sale_item: sale_item,
                           o_product_id: product_id,
                           o_feature_item_id: feature_item_id,
                           o_quantity: sale_item.quantity,
                           o_to_see: sale_item.to_see,
                           o_p_discount: sale_item.p_discount,
                           o_discount: sale_item.discount)
  sale_item.product_id = params[:product_id]
  sale_item.feature_item_id = params[:feature_item_id]
  sale_item.quantity = params[:quantity]
  sale_item.to_see = params[:to_see]
  sale_item.p_discount = params[:p_discount]
  sale_item.discount = params[:discount]
  log.product_id = sale_item.product_id
  log.feature_item_id = sale_item.feature_item_id
  log.quantity = sale_item.quantity
  log.to_see = sale_item.to_see
  log.p_discount = sale_item.p_discount
  log.discount = sale_item.discount
  sale_item.bought_quantity = quantity if sale_item.bought_quantity.present?
  sale_item.back_quantity = quantity if sale_item.back_quantity.present?

  price = if sale_item.p_discount.present?
            sale_item.p_discount
          elsif sale_item.discount.present?
            sale_item.price - ApplicationController.helpers.get_percentage(sale_item.discount, sale_item.price)
          else
            sale_item.price
          end
  sale_item.sum_price = sale_item.quantity * price
  sale_item.save
  log.save
  # Барааг нь сольсон бол үлдэгдэл тооцоно
  if product_id.present? && product_id != sale_item.product_id
    product = Product.find(product_id)
    product.update_column(:balance, product.balance_sum)
  end
  load_at = nil
  salesman_at = nil
  product_sale = sale_item.product_sale
  salesman_travel_id = product_sale.salesman_travel_id
  salesman_travel = SalesmanTravel.find(salesman_travel_id)
  warehouse_locs = ProductWarehouseLoc.by_travel(salesman_travel_id)
  # Шинж чанар сольсон бол
  if feature_item_id.present? && feature_item_id != sale_item.feature_item_id
    feature_item = ProductFeatureItem.find(feature_item_id)
    feature_item.update_column(:balance, feature_item.balance_sum)
    warehouse_locs = warehouse_locs.by_feature_item_id(feature_item_id)
    warehouse_locs.destroy_all if warehouse_locs.present?
  end
  if warehouse_locs.present?
    warehouse_loc = warehouse_locs.last
    load_at = warehouse_loc.load_at
    salesman_at = warehouse_loc.salesman_at
  end

  # Нийлбэр дүнг дахин бодох
  product_sale.update_sum_price

  create_warehouse_loc(salesman_travel.product_sale_items.by_feature_item_id(sale_item.feature_item_id).sum(:quantity),
                       salesman_travel_id,
                       sale_item.product_id,
                       sale_item.feature_item_id,
                       false, load_at, salesman_at)
  render json: {status: status, message: message}
end

# app/models/salesman_travel_route.rb

def create_warehouse_location
  if is_update.present?
    self.product_sale.update_column(:salesman_travel_id, salesman_travel_id)
    warehouse_locs = ProductWarehouseLoc.by_travel(salesman_travel_id)
    feature_item_ids = product_sale
                           .product_sale_items
                           .select("feature_item_id")
                           .group(:feature_item_id)
    load_at = nil
    salesman_at = nil
    if warehouse_locs.present?
      warehouse_loc = warehouse_locs.last
      load_at = warehouse_loc.load_at
      salesman_at = warehouse_loc.salesman_at
      feature_item_ids.each {|id|
        warehouse_locs = warehouse_locs.by_feature_item_id(id['feature_item_id'])
        warehouse_locs.destroy_all if warehouse_locs.present?
      }
    end
    feature_item_ids.each {|id|
      feature_item = ProductFeatureItem.find(id['feature_item_id'])
      create_warehouse_loc(salesman_travel
                               .product_sale_items
                               .by_feature_item_id(feature_item.id)
                               .sum(:quantity),
                           salesman_travel_id,
                           feature_item.product_id,
                           feature_item.id,
                           false, load_at, salesman_at)
    }
  end
end

def destroy_warehouse_loc
  # Шинж чанар агуулсан байршилуудыг олж устгана
  if is_update.present?
    warehouse_locs = ProductWarehouseLoc.by_travel(salesman_travel_id)
    self.feature_item_ids = product_sale
                                .product_sale_items
                                .select("feature_item_id")
                                .group(:feature_item_id)
    if warehouse_locs.present?
      self.feature_item_ids.each {|id|
        warehouse_locs = warehouse_locs.by_feature_item_id(id['feature_item_id'])
        warehouse_locs.destroy_all if warehouse_locs.present?
      }
    end
  end
end

def after_destroy_warehouse_loc
  # устгасаны дараа Шинж чанар агуулсан байвал шинээр үүсгэнэ
  if is_update.present?
    self.product_sale.update_column(:salesman_travel_id, nil)
    self.feature_item_ids.each {|id|
      item = product_sale
                 .product_sale_items.by_id(id['feature_item_id'])
      if item.present?
        feature_item = ProductFeatureItem.find(id['feature_item_id'])
        warehouse_locs = ProductWarehouseLoc.by_travel(salesman_travel_id)
                             .by_feature_item_id(feature_item.id)
        load_at = nil
        salesman_at = nil
        if warehouse_locs.present?
          warehouse_loc = warehouse_locs.last
          load_at = warehouse_loc.load_at
          salesman_at = warehouse_loc.salesman_at
        end
        create_warehouse_loc(salesman_travel
                                 .product_sale_items
                                 .by_feature_item_id(feature_item.id)
                                 .sum(:quantity),
                             salesman_travel_id,
                             feature_item.product_id,
                             feature_item.id,
                             false, load_at, salesman_at)
      end
    }
  end
end