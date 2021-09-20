module API
  module SALESMAN
    class Travels < Grape::API
      resource :travels do
        resource :open do
          desc "GET travels/open"
          get do
            salesman = current_salesman
            travels = SalesmanTravel.open_delivery(salesman.id)
            if travels.present?
              travel = travels.first
              if travel.load_at.nil?
                error!(I18n.t('errors.messages.stockkeeper_is_not_signed'), 422)
              elsif travel.sign_at.nil?
                error!(I18n.t('errors.messages.salesman_is_not_signed'), 422)
              else
                present :travel, travels.first, with: API::SALESMAN::Entities::SalesmanTravels
              end
            else
              error!(I18n.t('errors.messages.not_found'), 422)
            end
          end
        end

        desc "POST travels"
        params do
          requires :date, type: DateTime
        end
        post do
          salesman = current_salesman
          travels = SalesmanTravel.by_signed
                        .travels(salesman.id, ApplicationController.helpers.local_date(params[:date]))
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

          resource :products do
            desc "GET travels/:id/products"
            get do
              present :products, ProductWarehouseLoc.by_travel(params[:id]), with: API::SALESMAN::Entities::ProductWarehouse
            end

            route_param :pid do
              resource :load do
                desc "PATCH travels/:id/products/:pid/load"
                patch do
                  # salesman_travel = SalesmanTravel.find(params[:id])
                  warehouse_loc = ProductWarehouseLoc.find(params[:pid])
                  warehouse_loc.update_column(:salesman_at, Time.now)
                  present :load_at, warehouse_loc.salesman_at
                end
              end
            end

            # Устах үеийн статус
            resource :status do
              desc "POST travels/:id/products/status"
              post do
                status = LogStat.order_queue
                present :status, status, with: API::SALESMAN::Entities::LogStatus
              end
            end
            resource :delete do
              desc "PATCH travels/:id/products/delete"
              params do
                requires :id, type: Integer
                requires :quantity, type: Integer
                requires :status_id, type: Integer
              end
              patch do
                present :products, ProductWarehouseLoc.by_travel(params[:id]), with: API::SALESMAN::Entities::ProductWarehouse
              end
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
                if salesman_travel.load_sum == salesman_travel.salesman_at_count
                  image = params[:image] || {}
                  travel_sign = salesman_travel.salesman_travel_sign
                  travel_sign.received = image[:tempfile]
                  travel_sign.received_file_name = image[:filename]
                  travel_sign.save
                  salesman_travel.salesman_sign

                  present :sign_at, salesman_travel.sign_at
                else
                  error!(I18n.t('errors.messages.barcode_not_checked'), 422)
                end
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
                                  salesman_travel_route = SalesmanTravelRoute
                                                              .by_travel_id(travel_route.salesman_travel_id)
                                                              .by_queue(travel_route.queue - 1).first
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
                    is_success = false
                    product_sale_item = ProductSaleItem.find(params[:p_item_id])

                    if params[:skip_barcode].present? && params[:skip_barcode]
                      is_success = true
                    elsif params[:barcode].present?
                      if product_sale_item.feature_item.barcode == params[:barcode]
                        is_success = true
                      else
                        error!("Couldn't find by barcode", 422)
                      end
                    end
                    if is_success
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
                        product_sale_item.update_columns(bought_quantity: nil, bought_at: nil, bought_price: nil)
                        travel_route.calculate_payable # өгөх төлбөр болон хүргэлтийн огноо, хугацааг авна
                        message = I18n.t('alert.removed_successfully')
                      else
                        quantity_was = product_sale_item.quantity - (product_sale_item.back_quantity.presence || 0)
                        if params[:quantity] > 0 && params[:quantity] <= quantity_was
                          product_sale_item.update_columns(bought_quantity: params[:quantity], bought_at: Time.now, bought_price: product_sale_item.price * params[:quantity])
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
                        {message: message, payable: travel_route.payable, shipping: Const::SHIPPING_FEE, back_money: product_sale.back_money}
                      else
                        error!(message, r_s)
                      end
                    end
                  end
                end
              end

              resource :take do
                desc "PATCH travels/routes/:id/product/take"
                params do
                  requires :return_id, type: Integer
                  requires :quantity, type: Integer
                end
                patch do
                  message = ""
                  r_s = 200
                  salesman = current_salesman
                  product_sale_return = ProductSaleReturn.find(params[:return_id])
                  travel_route = SalesmanTravelRoute.find(params[:id])

                  product_sale = product_sale_return.product_sale
                  travel = product_sale.salesman_travel

                  if travel.present? && salesman.id == travel.salesman_id
                    if product_sale_return.take_at.present?
                      product_sale_return.update_columns(take_quantity: nil, take_at: nil)
                      message = I18n.t('alert.removed_successfully')
                    else
                      quantity_was = product_sale_return.quantity - (product_sale_return.take_quantity.presence || 0)
                      if params[:quantity] > 0 && params[:quantity] <= quantity_was
                        product_sale_return.update_columns(take_quantity: params[:quantity], take_at: Time.now)
                        product_sale_return.exchange_balance
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
                      {message: message, payable: travel_route.payable, shipping: Const::SHIPPING_FEE, back_money: product_sale.back_money}
                    else
                      error!(message, r_s)
                    end
                  end
                end
              end
            end

            resource :payable do
              desc "GET travels/routes/:id/payable"
              get do
                travel_route = SalesmanTravelRoute.find(params[:id])
                {payable: travel_route.main_payable, shipping: Const::SHIPPING_FEE, back_money: travel_route.product_sale.back_money}
              end
            end

            resource :register do
              desc "PATCH travels/routes/:id/register"
              #{0=Бэлнээр, 1=Дансаар, 2=Бэлнээр+Дансаар, 3=Авхаа больсон, 4=Хойшлуулсан, 5=Буруу захилга}
              params do
                requires :status, type: String
                optional :description, type: String
                optional :day, type: DateTime
                optional :hour, type: Integer
              end
              patch do
                message = ""
                r_s = 200
                salesman = current_salesman
                travel_route = SalesmanTravelRoute.find(params[:id])
                travel = travel_route.salesman_travel

                if travel.present? && salesman.id == travel.salesman_id
                  if params[:status] == "sals_delivered" # Авсан
                    product_sale = travel_route.product_sale
                    if travel_route.main_payable.present? || product_sale.is_return
                      travel_route.update_column(:delivery_at, Time.current) unless travel_route.delivery_at.present? #буцаалт үед nil байсан байж болно
                      travel_route.calculate_delivery
                      travel_route.calculate_wage
                      travel.update_column(:load_at, Time.current) unless travel.load_at.present? #буцаалт үед nil байсан байж болно
                      travel.calculate_delivery
                      status = ProductSaleStatus.find_by_alias("sals_delivered")
                      product_sale.salesman = salesman
                      product_sale.status = status
                      product_sale.save(validate: false)
                      product_sale.add_bonus
                      product_sale.remove_bonus
                      r_s = 200
                      message = I18n.t('alert.info_updated')
                    else
                      r_s = 422
                      message = I18n.t('activerecord.errors.models.salesman.attributes.payable.empty')
                    end
                  else # Аваагүй
                    if (travel_route.has_any_bought.presence || 0) > 0
                      r_s = 422
                      message = I18n.t('activerecord.errors.models.salesman.attributes.payable.not_empty')
                    else
                      r_s = 200
                      travel_route.calculate_delivery
                      travel.calculate_delivery
                      product_sale = travel_route.product_sale
                      status = ProductSaleStatus.find_by_alias(params[:status])
                      product_sale.salesman = salesman
                      product_sale.status = status
                      product_sale.status_note = params[:description]
                      if params[:status] == "sals_change_date" && params[:day].present? && params[:hour].present?
                        day = ApplicationController.helpers.local_date(params[:day].to_date)
                        product_sale.tmp_start = day.change({hour: params[:hour] - 1})
                        product_sale.tmp_end = day.change({hour: params[:hour] + 1})
                        product_sale.status_note = "#{product_sale.status_note}, цагаа #{product_sale.tmp_start.strftime('%Y/%m/%d') + '&nbsp;&nbsp;' + product_sale.tmp_start.hour.to_s + "-" + product_sale.tmp_end.hour.to_s} гэж өөрчилсөн"
                      end

                      product_sale.save(validate: false)
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