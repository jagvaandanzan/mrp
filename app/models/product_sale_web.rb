class ProductSaleWeb
  include Singleton

  def create(code, payment)
    param = {
        code: code,
        pay: payment
    }
    response = ApplicationController.helpers.api_request('sales/payment', 'post', param.to_json)
    if response.code.to_i == 201
      it_items = []
      json = JSON.parse(response.body)
      cart = json['cart']
      l = cart['location']
      d = cart['delivery_date'].split("-").map(&:to_i)
      start_time = cart['start_time'].split(":").map(&:to_i)
      end_time = cart['end_time'].split(":").map(&:to_i)

      product_sale = ProductSale.new(phone: cart['phone'],
                                     hour_start: start_time[0],
                                     hour_end: end_time[0],
                                     loc_note: cart['description'],
                                     delivery_start: Time.zone.local(d[0], d[1], d[2], start_time[0]),
                                     delivery_end: Time.zone.local(d[0], d[1], d[2], end_time[0]),
                                     sum_price: cart['payment'],
                                     bonus: cart['bonus'],
                                     money: 1,
                                     paid: cart['payment'],
                                     cart_id: cart['id'])

      if l['mrp_location_id'].present?
        product_sale.location = Location.find(l['mrp_location_id'])
        product_sale.status = ProductSaleStatus.find_by_alias("oper_confirmed")
      else
        loc_khoroo = LocKhoroo.find(l['loc_khoroo_id'])
        nl = Location.new(loc_district_id: loc_khoroo.loc_district_id,
                          loc_khoroo_id: l['loc_khoroo_id'],
                          micro_region: l['micro_region'],
                          town: l['town'],
                          street: l['street'],
                          apartment: l['apartment'],
                          entrance: l['entrance'],
                          latitude: l['latitude'],
                          longitude: l['longitude'],
                          approved: false,
                          web_location_id: l['id'])
        nl.save(validate: false)
        product_sale.location = nl
        product_sale.status = ProductSaleStatus.find_by_alias("oper_from_web")
      end

      cart['cart_items'].each do |item|
        sale_item = ProductSaleItem.new(product_id: item['product_id'])
        feature_item = ProductFeatureItem.find(item['product_feature_item_id'])
        sale_item.feature_item = feature_item
        sale_item.remainder = feature_item.balance
        sale_item.quantity = item['quantity']
        sale_item.p_price = feature_item.price.presence || 0
        sale_item.p_6_8 = feature_item.p_6_8.presence || 0
        sale_item.p_9_ = feature_item.p_9_.presence || 0
        sale_item.price = feature_item.price_quantity(sale_item.quantity).presence || 0
        # Хэрэв хямдралтай бол
        product_discounts = sale_item.product.product_discounts.by_available
        if product_discounts.present?
          discount = product_discounts.first
          sale_item.discount = discount.percent
          sale_item.price -= ApplicationController.helpers.get_percentage(sale_item.price, discount.percent)
        end
        sum_price = sale_item.price * sale_item.quantity
        sale_item.sum_price = sum_price

        product_sale.product_sale_items << sale_item

        if feature_item.barcode.present?
          it_items << {quantity: sale_item.quantity, serial_barcode: feature_item.barcode}
        end
      end

      if product_sale.save
        ApplicationController.helpers.send_sms(product_sale.phone, "Tani zahialga batalgaajlaa. Market.mn")
        param = {
            phone: product_sale.phone,
            address: product_sale.location.address,
            method: "account",
            order_id: code.to_i + 50000100,
            items: it_items
        }
        response = ApplicationController.helpers.sent_itoms("http://43.231.114.241:8882/api/mrp-enquire", 'post', param.to_json)
        # Rails.logger.debug("43.231.114.241:8882/api/mrp-enquire => #{param.to_json}")
        Rails.logger.debug("43.231.114.241:8882/api/mrp-enquire => #{response.code.to_s} => #{response.body.to_s}")
      else
        Rails.logger.debug("SAVE_zahialga: #{product_sale.errors.full_messages}")
        ApplicationController.helpers.send_sms(product_sale.phone, "Tani zahialga amjiltgui bolloo. Ta 7777-9990 dugaart handana uu?")
      end
    end
  end
end