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

            travels = SalesmanTravel.by_load_at(params[:signed], date)
            present :travels, travels, with: API::USER::Entities::SalesmanTravels
          end

        end

        route_param :id do
          resource :products do
            desc "GET travels/:id/products"
            get do
              salesman_travel = SalesmanTravel.find(params[:id])
              if salesman_travel.product_warehouse_locs.count == 0
                # Тавиурын хаана байгаа дарааллыг бодож гаргана
                product_sale_items = ProductFeatureItem.by_travel_id(salesman_travel.id)
                product_sale_items.each {|item|
                  feature_item = ProductFeatureItem.find(item.feature_item_id)
                  product_locations = ProductLocation.get_quantity(item.feature_item_id)
                  quantity = 0
                  product_locations.each {|loc|
                    if quantity < item.quantity
                      q = if loc.quantity >= (item.quantity - quantity)
                            item.quantity - quantity
                          else
                            loc.quantity
                          end
                      quantity += q
                      salesman_travel.product_warehouse_locs << ProductWarehouseLoc.new(product: feature_item.product,
                                                                                        location_id: loc.id,
                                                                                        feature_item_id: item.feature_item_id,
                                                                                        quantity: q)
                    else
                      break
                    end
                  }
                }
                salesman_travel.save(validate: false)

                present :products, salesman_travel.product_warehouse_locs, with: API::USER::Entities::ProductWarehouse
              else
                present :products, ProductWarehouseLoc.by_travel(params[:id]), with: API::USER::Entities::ProductWarehouse
              end
            end
          end

          resource :signature do
            desc "POST travels/:id/signature"
            params do
              requires :image, type: File
            end
            post do
              user = current_user
              salesman_travel = SalesmanTravel.find(params[:id])
              if user.is_stockkeeper? && salesman_travel.load_at.nil?
                image = params[:image] || {}
                travel_sign = SalesmanTravelSign.create({
                                                            salesman_travel: salesman_travel,
                                                            user: user,
                                                            given: image[:tempfile],
                                                            given_file_name: image[:filename]
                                                        })
                salesman_travel.on_sign(user)
                present :sign_at, travel_sign.created_at
              else
                error!("Couldn't find data", 422)
              end
            end

            resource :check do
              desc "GET travels/:id/check"
              get do
                user = current_user
                salesman_travel = SalesmanTravel.find(params[:id])
                if user.is_stockkeeper?
                  not_load = salesman_travel.product_warehouse_locs.by_load_at(false).count
                  present :sign_approve, salesman_travel.load_at.nil? && not_load == 0
                else
                  error!("Couldn't find data", 422)
                end
              end
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
                is_success = false
                warehouse_locs = ProductWarehouseLoc.by_travel(nil, params[:id])
                warehouse_loc = warehouse_locs.first
                if params[:skip_barcode].present? && params[:skip_barcode]
                  is_success = true
                elsif params[:barcode].present?
                  if warehouse_loc.barcode == params[:barcode]
                    is_success = true
                  else
                    error!("Couldn't find by barcode", 422)
                  end
                end

                if is_success
                  present :warehouse_loc, warehouse_loc, with: API::USER::Entities::ProductWarehouse
                else
                  error!("Couldn't find data", 422)
                end
              end
            end

            resource :load do
              desc "PATCH travels/products/:id/load"
              patch do
                warehouse_loc = ProductWarehouseLoc.find(params[:id])
                warehouse_loc.update_column(:load_at, Time.now)

                present :load_at, warehouse_loc.load_at
              end
            end
          end
        end

      end
    end
  end
end