class MySingleton
  include Singleton

  def salesman_calc(date, salesman_id)

    product_sales = ProductSale.joins(:salesman_travel)
                        .where("salesman_travels.salesman_id = ?", salesman_id)
                        .where('salesman_travels.delivery_at >= ?', date)
                        .where('salesman_travels.delivery_at < ?', date + 1.days)
                        .where('product_sales.status_id >= ? AND product_sales.status_id <= ? ', 12, 14)

    q = 0 # Нийт тоо ширхэг
    price = 0 #Нийт дүн
    back_sum = 0 #Буцаалт
    acc_sum = 0 #Дансаар
    cash_sum = 0 #Бэлнээр
    bought_sum = 0
    bonus = 0
    product_sales.each do |product_sale|
      sale_items = product_sale.product_sale_items.not_nil_bought_quantity
      bonus += product_sale.bonus.presence || 0
      acc_sum += product_sale.paid if product_sale.paid.present?
      if sale_items.present?
        sale_items.each {|item|
          q += item.bought_quantity
          price += item.bought_price
          bought_sum += item.bought_price
        }
      end
      # Буцаалт, солилт
      if product_sale.parent_id.present?
        b_price = product_sale.return_price
        if bought_sum == 0 # Хэрэв буцаалт бол
          back_sum += b_price
        else # Солилт
          p = bought_sum - b_price - (product_sale.paid.presence || 0)
          if p < 0
            p *= -1
            back_sum += p
          else # Хэрэглэгчийн төлөх мөнгө үлдсэн бол
            cash_sum += p
          end
        end
      else
        p = product_sale.paid.present? ? bought_sum - product_sale.paid : bought_sum
        cash_sum += p
      end

      shipping_pay = (bought_sum < Const::FREE_SHIPPING && bought_sum > 0) ? Const::SHIPPING_FEE : 0
      cash_sum += shipping_pay
      price += shipping_pay

      bought_sum = 0
    end

    sale_directs = ProductSaleDirect.by_salesman_id(salesman_id)
                       .date_between(date)
    p = sale_directs.sum(:sum_price)
    q += sale_directs.sum(:quantity)
    price += p
    cash_sum += p

    # logger.info("Нийт: #{price}")
    # logger.info("Буцаалт: #{back_sum}")
    # logger.info("Дансаар: #{acc_sum}")
    # logger.info("Бэлнээр: #{cash_sum}")
    # logger.info("Бонус: #{bonus}")
    # logger.info("ТҮГЭЭГЧЭЭС АВАХ БЭЛЭН МӨНГӨ: #{cash_sum - back_sum - bonus}")
    [q, price, back_sum, acc_sum, cash_sum, bonus, cash_sum - back_sum - bonus]

  end

  def copy_sale(sale)
    new_sale = ProductSale.new(delivery_start: sale.delivery_start, delivery_end: sale.delivery_end, phone: sale.phone,
                               location_id: sale.location_id, country: sale.country, building_code: sale.building_code, loc_note: sale.loc_note,
                               money: sale.money, paid: sale.paid, bonus: sale.bonus, sum_price: sale.sum_price, status_note: sale.status_note,
                               source: sale.source, sale_call_id: sale.sale_call_id, created_operator_id: sale.created_operator_id, approved_operator_id: sale.approved_operator_id,
                               approved_date: sale.approved_date, cart_id: sale.cart_id, feedback_period: sale.feedback_period, tax: sale.tax)

    sale.product_sale_items.with_deleted.each do |sale_item|
      feature_item = sale_item.feature_item
      new_sale.product_sale_items << ProductSaleItem.new(product_id: sale_item.product_id, feature_item_id: sale_item.feature_item_id,
                                                         quantity: sale_item.quantity, price: sale_item.price, p_discount: sale_item.p_discount,
                                                         remainder: feature_item.balance,
                                                         p_price: feature_item.price.presence || 0,
                                                         p_6_8: feature_item.p_6_8.presence || 0,
                                                         p_9_: feature_item.p_9_.presence || 0,
                                                         sum_price: sale_item.sum_price, to_see: sale_item.to_see)
    end
    if sale.product_sale_status_logs.present?
      log = sale.product_sale_status_logs.last
      new_sale.product_sale_status_logs << ProductSaleStatusLog.new(operator_id: log.operator_id, salesman_id: log.salesman_id,
                                                                    status_id: log.status_id, log_type: log.log_type, note: log.note)
    end

    new_sale
  end
end