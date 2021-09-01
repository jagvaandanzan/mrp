class Users::DeliveryReportsController < Users::BaseController
  authorize_resource class: false

  def index
    @salesman_id = params[:salesman_id]
    @date = if params[:date].present?
              params[:date].to_date
            else
              Time.current.beginning_of_day
            end

    travers = SalesmanTravel.travels(@salesman_id, @date)

    @product_sales = ProductSale.by_travel_ids(travers.map(&:id).to_a)
                         .by_delivered
                         .order(:phone)
    @sale_directs = ProductSaleDirect.by_salesman_id(@salesman_id)
                        .date_between(@date)
                        .order(:phone)
    # date = Time.zone.local(2021, 8, 21)
    # product_sales = ProductSale.joins(:salesman_travel)
    #                     .where("salesman_travels.salesman_id = ?", 23)
    #                     .where('salesman_travels.delivery_at >= ?', date)
    #                     .where('salesman_travels.delivery_at < ?', date + 1.days)
    #                     .where('product_sales.status_id >= ? AND product_sales.status_id <= ? ', 12, 14)
    #
    # q = 0 # Нийт тоо ширхэг
    # price = 0 #Нийт дүн
    # back_sum = 0 #Буцаалт
    # acc_sum = 0 #Дансаар
    # cash_sum = 0 #Бэлнээр
    # bought_sum = 0
    #
    # product_sales.each do |product_sale|
    #   sale_items = product_sale.product_sale_items.not_nil_bought_quantity
    #   acc_sum += product_sale.paid if product_sale.paid.present?
    #   if sale_items.present?
    #     sale_items.each {|item|
    #       q += item.bought_quantity
    #       price += item.bought_price
    #       bought_sum += item.bought_price
    #     }
    #   end
    #   # Буцаалт, солилт
    #   if product_sale.parent_id.present?
    #     b_price = product_sale.return_price
    #     if bought_sum == 0 # Хэрэв буцаалт бол
    #       back_sum += b_price
    #     else # Солилт
    #       p = bought_sum - b_price - (product_sale.paid.presence || 0)
    #       if p < 0
    #         p *= -1
    #         back_sum += p
    #       else # Хэрэглэгчийн төлөх мөнгө үлдсэн бол
    #         cash_sum += p
    #       end
    #     end
    #   else
    #     p = product_sale.paid.present? ? bought_sum - product_sale.paid : bought_sum
    #     cash_sum += p
    #   end
    #
    #   bought_sum = 0
    # end
    #
    # sale_directs = ProductSaleDirect.by_salesman_id(23)
    #                    .date_between(date)
    # p = sale_directs.sum(:sum_price)
    # q += sale_directs.sum(:quantity)
    # price += p
    # cash_sum += p
    #
    # logger.info("Нийт: #{price}")
    # logger.info("Буцаалт: #{back_sum}")
    # logger.info("Дансаар: #{acc_sum}")
    # logger.info("Бэлнээр: #{cash_sum}")
    # logger.info("ТҮГЭЭГЧЭЭС АВАХ БЭЛЭН МӨНГӨ: #{cash_sum - back_sum}")
  end

  def salary
    @by_start = params[:by_start]
    @by_end = params[:by_end]
    @salesman_id = params[:salesman_id]
    today = Time.current.beginning_of_day
    @by_start = today.strftime("%Y/%m/%d") unless @by_start.present?
    @by_end = today.strftime("%Y/%m/%d") unless @by_end.present?

    if @salesman_id.present?
      @travel_routes = SalesmanTravelRoute.not_ni_wage
                           .search(@by_start.to_date, @by_end.to_date, params[:salesman_id])
    end

  end

end
