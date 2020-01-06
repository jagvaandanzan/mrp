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

        resource :products do
          route_param :id do
            resource :scan do
              desc "POST travels/products/:id/scan"
              params do
                optional :barcode, type: String
                optional :skip_barcode, type: Boolean
              end
              post do
                if params[:barcode].present? || (params[:skip_barcode].present? && params[:skip_barcode])
                  products = ProductWarehouseLoc.by_travel(nil, params[:id])
                  present :product, products.first, with: API::USER::Entities::ProductWarehouse
                else
                  error!("Couldn't find data", 422)
                end
              end
            end

            resource :load do
              desc "PATCH travels/products/:id/load"
              patch do
                warehouse_loc = ProductWarehouseLoc.find(params[:id])
                warehouse_loc.load_at = Time.now
                warehouse_loc.save

                present :load_at, warehouse_loc.load_at
              end
            end
          end
        end

      end
    end
  end
end