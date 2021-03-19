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
            delivered = routes.by_status('sals_delivered')

            status_ids = ProductSaleStatus.by_aliases(%w(call_order sals_delivered))
            contain_exchange = delivered.contain_exchange(true).select("COUNT(DISTINCT salesman_travel_routes.id) as cnt")
            exchange = if contain_exchange.present?
                         contain_exchange.first[:cnt]
                       else
                         0
                       end

            present :delivered, delivered.count
            present :not_delivered, routes.by_not_status(status_ids.map(&:id).to_a).count
            present :exchange, exchange
          end
        end

        resource :performance do
          desc "POST report/performance"
          params do
            requires :start_time, type: DateTime
            requires :end_time, type: DateTime
          end
          post do
            delivered = SalesmanTravelRoute.by_salesman_id(current_salesman.id)
                            .by_day(ApplicationController.helpers.local_date(params[:start_time]),
                                    ApplicationController.helpers.local_date(params[:end_time]))
                            .by_status('sals_delivered')

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
            requires :start_time, type: DateTime
            requires :end_time, type: DateTime
          end
          post do

            sale_items = ProductSaleItem.report_sale_delivered(current_salesman.id, params[:start_time], params[:end_time])
            sales = ProductSale.report_sale_delivered(current_salesman.id, params[:start_time], params[:end_time])

            present :sales, sales.present? ? sales.first : nil, with: API::SALESMAN::Entities::ReportMoney
            present :back_money, 0
            present :sale_items, sale_items, with: API::SALESMAN::Entities::ReportCash
          end
        end

      end
    end
  end
end
