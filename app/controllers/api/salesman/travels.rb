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

        desc "POST travels"
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

          resource :signature do
            desc "POST travels/:id/signature"
            params do
              requires :image, type: File
            end
            post do
              salesman_travel = SalesmanTravel.find(params[:id])
              if salesman_travel.load_at.nil?
                error!(I18n.t('errors.messages.stockkeeper_is_not_signed'), 422)
              elsif salesman_travel.sign_at.nil?
                image = params[:image] || {}
                travel_sign = salesman_travel.salesman_travel_sign
                travel_sign.received = image[:tempfile]
                travel_sign.received_file_name = image[:filename]
                travel_sign.save
                salesman_travel.update_column(:sign_at, Time.now)

                present :sign_at, salesman_travel.sign_at
              else
                error!("Couldn't find data", 422)
              end
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

            resource :product do
              route_param :p_item_id do
                desc "GET travels/routes/:id/product/:p_item_id"
                get do
                  product_sale_item = ProductSaleItem.find(params[:p_item_id])
                  present :product, product_sale_item, with: API::SALESMAN::Entities::ProductSaleItemDetail
                end

                resource :scan do
                  desc "POST travels/routes/:id/product/:p_item_id/scan"
                  params do
                    optional :barcode, type: String
                    optional :skip_barcode, type: Boolean
                  end
                  post do
                    if params[:barcode].present? || (params[:skip_barcode].present? && params[:skip_barcode])
                      product_sale_item = ProductSaleItem.find(params[:p_item_id])
                      present :product, product_sale_item, with: API::SALESMAN::Entities::ProductSaleItemBarCode
                    else
                      error!("Couldn't find data", 422)
                    end
                  end
                end

                resource :bought_by_product do
                  desc "PATCH travels/routes/:id/product/:p_item_id/bought_by_product"
                  params do
                    requires :quantity, type: Integer
                  end
                  patch do
                    message = ""
                    r_s = 200
                    salesman = current_salesman
                    product_sale_item = ProductSaleItem.find(params[:p_item_id])
                    travel_route = SalesmanTravelRoute.find(params[:id])
                    product_sale = product_sale_item.product_sale
                    travel = product_sale.salesman_travel

                    if travel.present? && salesman.id == travel.salesman_id
                      if product_sale_item.bought_at.present?
                        product_sale_item.update_columns(bought_quantity: nil, bought_at: nil)
                        travel_route.calculate_payable # өгөх төлбөр болон хүргэлтийн огноо, хугацааг авна
                        message = I18n.t('alert.removed_successfully')
                      else
                        quantity_was = product_sale_item.quantity - (product_sale_item.back_quantity.presence || 0)
                        if params[:quantity] > 0 && params[:quantity] <= quantity_was
                          product_sale_item.update_columns(bought_quantity: params[:quantity], bought_at: Time.now)
                          travel_route.calculate_payable
                          message = I18n.t('alert.info_updated')
                        else
                          r_s = 422
                          message = I18n.t('activerecord.attributes.product_sale_item.quantity') +
                              I18n.t('errors.messages.less_than_or_equal_to', count: quantity_was)
                        end
                      end
                    end

                    if message.empty?
                      error!("Couldn't find data", 404)
                    else
                      if r_s == 200
                        {message: message, payable: travel_route.payable}
                      else
                        error!(message, r_s)
                      end
                    end
                  end
                end
              end
            end

            resource :payable do
              desc "GET travels/routes/:id/payable"
              get do
                travel_route = SalesmanTravelRoute.find(params[:id])
                {payable: travel_route.main_payable}
              end
            end

            resource :register do
              desc "PATCH travels/routes/:id/register"
              #{0=Бэлнээр, 1=Дансаар, 2=Бэлнээр+Дансаар, 3=Авхаа больсон, 4=Хойшлуулсан, 5=Буруу захилга}
              params do
                requires :status, type: Integer
              end
              patch do
                message = ""
                r_s = 200
                salesman = current_salesman
                travel_route = SalesmanTravelRoute.find(params[:id])
                travel = travel_route.salesman_travel

                if travel.present? && salesman.id == travel.salesman_id
                  if params[:status] <= 2 # Авсан
                    if travel_route.main_payable.present?
                      travel_route.calculate_delivery
                      travel.calculate_delivery
                      status = ProductSaleStatus.find_by_alias("delivered")
                      product_sale = travel_route.product_sale
                      product_sale.update_columns(main_status_id: status.id, status_id: status.id)
                      r_s = 200
                      message = I18n.t('alert.info_updated')
                    else
                      r_s = 422
                      message = I18n.t('activerecord.errors.models.salesman.attributes.payable.empty')
                    end
                  else # Аваагүй
                    if travel_route.main_payable.present?
                      r_s = 422
                      message = I18n.t('activerecord.errors.models.salesman.attributes.payable.not_empty')
                    else
                      r_s = 200
                      travel_route.calculate_delivery
                      travel.calculate_delivery
                      product_sale = travel_route.product_sale
                      case params[:status]
                      when 3 #Авхаа больсон
                        status = ProductSaleStatus.find_by_alias("not_buy")
                        product_sale.update_columns(main_status_id: status.id, status_id: status.id)
                      when 4 #Хойшлуулсан
                        main_status = ProductSaleStatus.find_by_alias("delay")
                        status = ProductSaleStatus.find_by_alias("delay_salesman")
                        product_sale.update_columns(main_status_id: main_status.id, status_id: status.id)
                      else #5, Буруу захилга
                        status = ProductSaleStatus.find_by_alias("wrong_book")
                        product_sale.update_columns(main_status_id: status.id, status_id: status.id)
                      end
                      message = I18n.t('alert.info_updated')
                    end
                  end
                end

                if message.empty?
                  error!("Couldn't find data", 404)
                else
                  if r_s == 200
                    {message: message}
                  else
                    error!(message, r_s)
                  end
                end
              end
            end
          end
        end
      end

    end
  end
end