module API
  module USER
    class Travels < Grape::API
      resource :travels do
        desc "POST travels"
        params do
          requires :signed, type: Boolean
          optional :date, type: DateTime
        end
        post do
          user = current_user
          if user.is_stockkeeper?
            date = if params[:date].present?
                     ApplicationController.helpers.local_date(params[:date])
                   else
                     nil #Time.now.beginning_of_day
                   end

            travels = SalesmanTravel.by_signed(params[:signed], date)
            present :travels, travels, with: API::USER::Entities::SalesmanTravels
          end

        end


        route_param :id do
          resource :products do
            desc "GET travels/:id/products"
            get do
              present :products, ProductWarehouseLoc.by_travel(params[:id]), with: API::USER::Entities::ProductWarehouse
            end
          end
        end

      end
    end
  end
end