module API
  module SALESMAN
    class Travels < Grape::API
      resource :travels do
        resource :open do
          desc "GET travels/open"
          get do
            salesman = current_salesman
            travels = SalesmanTravel.open_delivery(salesman.id)
            present :travel, travels.first, with: API::SALESMAN::Entities::SalesmanTravels
          end
        end

        desc "GET travels"
        params do
          requires :date, type: DateTime
        end
        post do
          salesman = current_salesman
          travels = SalesmanTravel.travels(salesman.id, ApplicationController.helpers.local_date(params[:date]))
          present :travels, travels, with: API::SALESMAN::Entities::SalesmanTravels
        end

        route_param :id do
          resource :routes do
            desc "GET travels/:id/routes"
            get do
              salesman = current_salesman
              travel = SalesmanTravel.by_id_and_salesman(params[:id], salesman.id).first
              present :routes, travel.salesman_travel_routes, with: API::SALESMAN::Entities::SalesmanTravelRoutes
            end
          end
        end

        resource :routes do
          route_param :id do
            desc "GET travels/routes/:id"
            get do
              travel_route = SalesmanTravelRoute.find(params[:id])
              present :route, travel_route, with: API::SALESMAN::Entities::SalesmanTravelRoute
            end

            resource :map do
              desc "GET travels/routes/:id/map"
              get do
                travel_route = SalesmanTravelRoute.find(params[:id])
                location_from = if travel_route.queue == 0
                                  Location.find(1)
                                else
                                  salesman_travel_route = SalesmanTravelRoute.by_queue(travel_route.salesman_travel_id, travel_route.queue - 1).first
                                  salesman_travel_route.location
                                end
                location_to = travel_route.location

                {lat_from: location_from.latitude, lng_from: location_from.longitude, lat_to: location_to.latitude, lng_to: location_to.longitude}
              end
            end

          end
        end
      end

    end
  end
end