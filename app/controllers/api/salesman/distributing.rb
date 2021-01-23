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
            d = Distributing.instance
            status, message, travel = d.create(salesman)

            if status == 201
              present :travel, travel, with: API::SALESMAN::Entities::SalesmanTravels
            else
              error!(message, 422)
            end
          end
        end

      end
    end
  end
end