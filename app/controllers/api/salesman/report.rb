module API
  module SALESMAN
    class Report < Grape::API
      resource :report do
        resource :delivery do
          desc "POST report/delivery"
          params do
            requires :start_time, type: DateTime
            requires :end_time, type: DateTime
          end
          post do
            dailies = SalesmanTravelRoute.by_daily(current_salesman.id)
                          .by_day(ApplicationController.helpers.local_date(params[:start_time]),
                                  ApplicationController.helpers.local_date(params[:end_time]))

            present :dailies, dailies, with: API::SALESMAN::Entities::TravelRouteDaily
          end
        end

        resource :routes do
          desc "POST report/routes"
          params do
            requires :start_time, type: DateTime
            requires :end_time, type: DateTime
          end
          post do
            routes = SalesmanTravelRoute.by_salesman_id(current_salesman.id)
                         .by_day(ApplicationController.helpers.local_date(params[:start_time]),
                                 ApplicationController.helpers.local_date(params[:end_time]))
            delivered_ids = ProductSaleStatus.by_aliases(%w(sals_delivered oper_replacement oper_return))
            delivered = routes.by_status_ids(delivered_ids.map(&:id).to_a)

            status_ids = ProductSaleStatus.by_aliases(%w(call_order sals_delivered oper_replacement oper_return))
            present :delivered, delivered.count
            present :not_delivered, routes.by_not_status(status_ids.map(&:id).to_a).count
            present :exchange, delivered.contain_exchange(true).count
          end
        end

        resource :performance do
          desc "POST report/performance"
          params do
            requires :start_time, type: DateTime
            requires :end_time, type: DateTime
          end
          post do
            delivered_ids = ProductSaleStatus.by_aliases(%w(sals_delivered oper_replacement oper_return))
            delivered = SalesmanTravelRoute.by_salesman_id(current_salesman.id)
                            .by_day(ApplicationController.helpers.local_date(params[:start_time]),
                                    ApplicationController.helpers.local_date(params[:end_time]))
                            .by_status_ids(delivered_ids.map(&:id).to_a)

            present :delivered, delivered.count
            present :can_delivery_time, delivered.can_delivery_time.count
          end
        end

        resource :salary_calculated do
          desc "POST report/salary_calculated"
          params do
            requires :start_time, type: DateTime
            requires :end_time, type: DateTime
          end
          post do
            routes = SalesmanTravelRoute.by_salesman_id(current_salesman.id)
                         .by_day(ApplicationController.helpers.local_date(params[:start_time]),
                                 ApplicationController.helpers.local_date(params[:end_time]))
            waged = routes.by_wage_nil(false)

            present :deliveries, routes.count
            present :waged, waged.count
          end
        end

        resource :cash do
          desc "POST report/cash"
          params do
            requires :date, type: DateTime
          end
          post do

            product_sales = ProductSale.joins(:salesman_travel)
                                .where("salesman_travels.salesman_id = ?", current_salesman.id)
                                .where('salesman_travels.delivery_at >= ?', params[:date])
                                .where('salesman_travels.delivery_at < ?', params[:date] + 1.days)
                                .where('product_sales.status_id >= ? AND product_sales.status_id <= ? ', 12, 14)
            q = 0 # Нийт тоо ширхэг
            price = 0 #Нийт дүн
            back_sum = 0 #Буцаалт
            acc_sum = 0 #Дансаар
            cash_sum = 0 #Бэлнээр
            bought_sum = 0
            items = []
            product_sales.each do |product_sale|
              sale_items = product_sale.product_sale_items.not_nil_bought_quantity
              acc_sum += product_sale.paid if product_sale.paid.present?
              if sale_items.present?
                sale_items.each {|item|
                  q += item.bought_quantity
                  price += item.bought_price
                  bought_sum += item.bought_price
                  items << item
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

              bought_sum = 0
            end

            sale_directs = ProductSaleDirect.by_salesman_id(current_salesman.id)
                               .date_between(params[:date])
            p = sale_directs.sum(:sum_price)
            q += sale_directs.sum(:quantity)
            price += p
            cash_sum += p

            # logger.info("Нийт: #{price}")
            # logger.info("Буцаалт: #{back_sum}")
            # logger.info("Дансаар: #{acc_sum}")
            # logger.info("Бэлнээр: #{cash_sum}")
            # logger.info("ТҮГЭЭГЧЭЭС АВАХ БЭЛЭН МӨНГӨ: #{cash_sum - back_sum}")

            {cass: {sale_items: items.as_json(:methods => [:sale_type, :product_code, :product_name, :product_feature, :phone], only: [:bought_quantity, :bought_price]),
                    quantity: q,
                    price: ApplicationController.helpers.get_currency_mn(price),
                    back_sum: ApplicationController.helpers.get_currency_mn(back_sum),
                    acc_sum: ApplicationController.helpers.get_currency_mn(acc_sum),
                    cash_sum: ApplicationController.helpers.get_currency_mn(cash_sum),
                    salesman: ApplicationController.helpers.get_currency_mn(cash_sum - back_sum)}}
            # present :quantity, q
            # present :price, price
            # present :back_sum, back_sum
            # present :acc_sum, acc_sum
            # present :cash_sum, cash_sum
          end
        end

      end
    end
  end
end

# class ReportSaleItem
#
#   attr_accessor :sale_type, :product_code, :product_name, :product_feature, :phone, :bought_quantity, :bought_price,
#
#   def initialize(attributes = {})
#     attributes.each do |name, value|
#       send("#{name}=", value)
#     end
#   end
#
# end
