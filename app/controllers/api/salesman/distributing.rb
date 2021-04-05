module API
  module SALESMAN
    class Distributing < Grape::API
      resource :distributing do
        desc "GET distributing"
        get do
          salesman = current_salesman
          travel = SalesmanTravel.open_delivery(salesman.id)
          if travel.present?
            present :travel, travel.first, with: API::SALESMAN::Entities::SalesmanTravels
          else
            yesterday = Time.current.yesterday.beginning_of_day
            income_ordered = salesman.income_ordered(yesterday)
            if income_ordered == 0

              d = Distribute.instance
              status, message, travel = d.create(salesman)

              if status == 201
                present :travel, travel, with: API::SALESMAN::Entities::SalesmanTravels
              else
                error!(message, 422)
              end
            else
              error!("Та #{ApplicationController.helpers.get_currency_mn(income_ordered)} тушаана уу!", 422)
            end
          end
        end

      end
    end
  end
end