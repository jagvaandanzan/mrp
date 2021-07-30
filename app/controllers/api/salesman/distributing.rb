module API
  module SALESMAN
    class Distributing < Grape::API
      resource :distributing do
        desc "GET distributing"
        get do
          salesman = current_salesman
          travel = SalesmanTravel.open_delivery(salesman.id)
          requested = SalesmanRequest.by_salesman_id(salesman.id)
                          .by_travel_nil
          if travel.present?
            present :travel, travel.first, with: API::SALESMAN::Entities::SalesmanTravels
          elsif requested.present?
            error!("Та хүсэлт илгээсэн байна!", 422)
          else
            return_signs = SalesmanReturnSign.by_salesman(salesman.id)
                               .by_user(nil)
            if return_signs.present?
              [422, I18n.t('errors.messages.return_request_not_confirmed')]
            else
              sale_items = ProductSaleItem.sale_available(salesman.id)
              if sale_items.present?
                [422, I18n.t('errors.messages.you_have_a_balance')]
              else
                yesterday = Time.current.yesterday.beginning_of_day
                income_ordered = salesman.income_ordered(yesterday)
                if income_ordered == 0
                  last_travels = SalesmanTravel.by_salesman(salesman.id)
                                     .last_delivered
                  salesman_request = SalesmanRequest.new
                  salesman_request.salesman = salesman
                  if last_travels.present?
                    last_travel = last_travels.last
                    salesman_request.last_travel_at = last_travel.delivered_at
                    salesman_request.last_route = last_travel.route_count
                  end

                  salesman_request.save
                  present :requested, true

                  # d = Distribute.instance
                  # status, message, travel = d.create(salesman)
                  # if status == 201
                  #   present :travel, travel, with: API::SALESMAN::Entities::SalesmanTravels
                  # else
                  #   error!(message, 422)
                  # end
                else
                  error!("Та #{ApplicationController.helpers.get_currency_mn(income_ordered)} тушаана уу!", 422)
                end
              end
            end
          end
        end

      end
    end
  end
end