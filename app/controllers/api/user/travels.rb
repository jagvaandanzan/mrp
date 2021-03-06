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
              travel_id = params[:id]
              salesman_travel = SalesmanTravel.find(travel_id)
              product_feature_items = ProductFeatureItem.by_travel_id(salesman_travel.id)

              # Тавиурын хаана байгаа дарааллыг бодож гаргана
              product_feature_items.each {|item|
                # Буцаалт бол алгасан
                if item[:quantity] > 0
                  feature_item = ProductFeatureItem.find(item.feature_item_id)
                  if feature_item.product_warehouse_locs.by_travel(travel_id).count == 0
                    create_warehouse_loc(item[:quantity].to_i, params[:id], feature_item.product_id, feature_item.id)
                  end
                end
              }
              salesman_travel.save(validate: false)

              if salesman_travel.product_warehouse_locs.count == 0
                error!(I18n.t('errors.messages.not_placed_on_desk'), 422)
              else
                # ямар нэг барааг тавиурт байршуулаагүйг тус бүр шалгана
                product_name = nil
                product_feature_items.each {|item|
                  if item[:quantity] > 0 # Буцаалт бол алгасан
                    feature_item = ProductFeatureItem.find(item.feature_item_id)
                    if feature_item.product_warehouse_locs.by_travel(travel_id).count == 0
                      product_name = "#{feature_item.product.full_name}, #{feature_item.name}"
                      break
                    end
                  end
                }
                if product_name.nil?
                  present :products, ProductWarehouseLoc.by_travel(params[:id]), with: API::USER::Entities::ProductWarehouse
                else
                  error!("#{product_name}: #{I18n.t('errors.messages.not_placed_on_desk')}", 422)
                end
              end
            end

            # Устах үеийн статус
            resource :status do
              desc "GET travels/:id/products/status"
              get do
                status = LogStat.order_queue
                present :status, status, with: API::USER::Entities::LogStatus
              end
            end
            resource :delete do
              desc "PATCH travels/:id/products/delete"
              params do
                requires :pid, type: Integer
                requires :quantity, type: Integer
                requires :status_id, type: Integer
              end
              patch do
                loc = ProductWarehouseLoc.find(params[:pid])
                q = params[:quantity]
                if loc.quantity == q
                  loc.destroy
                else
                  loc.update_column(:quantity, loc.quantity - q)
                end
                sale_items = ProductSaleItem.by_salesman_travel_id(loc.salesman_travel_id)
                                 .by_feature_item_id(loc.feature_item_id)
                destroy_q = 0
                # Эхлээд яг тэнцүү бараатай захиалгын устгая
                sale_items.each {|sale_item|
                  if sale_item.quantity == q
                    sale_item.destroy_from(q, current_user, params[:status_id])
                    destroy_q += sale_item.quantity
                  end
                }
                # Устгаж чадаагүй бол
                if destroy_q < q
                  sale_items.each {|sale_item|
                    if destroy_q > 0
                      if sale_item.quantity <= destroy_q
                        sale_item.destroy_from(destroy_q, current_user, params[:status_id])
                      else
                        sale_item.destroy_from(loc.quantity - q, current_user, params[:status_id])
                      end
                      destroy_q -= sale_item.quantity
                    else
                      break
                    end
                  }
                end

                present :success, true
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
                if salesman_travel.load_sum == salesman_travel.load_count
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
                  error!(I18n.t('errors.messages.barcode_not_checked'), 422)
                end
              else
                error!("Couldn't find data", 422)
              end
            end

            resource :check do
              desc "GET travels/:id/signature/check"
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

          resource :routes do
            desc "GET travels/:id/routes"
            get do
              salesman_travel = SalesmanTravel.find(params[:id])
              present :routes, salesman_travel.salesman_travel_routes, with: API::USER::Entities::SalesmanTravelRoutes
            end
          end

          resource :add_product do
            desc "POST travels/:id/add_product"
            params do
              requires :feature_id, type: Integer
              requires :quantity, type: Integer
            end
            post do
              salesman_travel = SalesmanTravel.find(params[:id])
              product_sale = salesman_travel.product_sales.first

              if salesman_travel.product_warehouse_locs.count > 0
                if salesman_travel.load_at.nil?
                  feature = ProductFeatureItem.find(params[:feature_id])

                  sale_item = ProductSaleItem.new(product_sale: product_sale,
                                                  product_id: feature.product_id,
                                                  feature_item: feature,
                                                  quantity: params[:quantity],
                                                  add_stock: true,
                                                  price: feature.price,
                                                  sum_price: feature.price * params[:quantity])

                  if sale_item.save
                    create_warehouse_loc(sale_item.quantity, params[:id], feature.product_id, feature.id, true)
                    present :added, sale_item.created_at
                  else
                    error!(sale_item.errors.full_messages, 422)
                  end

                else
                  error!(I18n.t('errors.messages.stockkeeper_is_signed'), 422)
                end
              else
                error!(I18n.t('errors.messages.access_delivery_item_first'), 422)
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
            # Шинэ бараа нэмж өгөхөд
            resource :features do
              desc "GET travels/products/:id/features"
              get do
                features = []
                product = Product.find(params[:id])
                img_url = if product.picture.present?
                            product.picture.url(:tumb)
                          else
                            "/images/orignal/missing.png"
                          end
                price = if product.price.present?
                          product.price
                        else
                          0
                        end
                product.product_feature_items.each do |item|
                  features.push({id: item.id,
                                 name: item.name,
                                 balance: item.balance,
                                 price: ApplicationController.helpers.get_currency_mn(item.price)})
                end

                present :img_url, img_url
                present :price, price
                present :features, features, with: API::USER::Entities::ProductFeatures
              end
            end
          end

          resource :search do
            desc "POST travels/products/search"
            params do
              requires :text, type: String
            end
            post do
              products = Product.search_by_name(params[:text])

              present :products, products, with: API::USER::Entities::Products
            end
          end
        end

      end
    end
  end
end

def create_warehouse_loc(item_quantity, salesman_travel_id, product_id, feature_item_id, add_stock = false, load_at = nil, salesman_at = nil)
  product_locations = ProductLocation.get_quantity(feature_item_id)
  quantity = 0
  is_added = false
  product_locations.each {|loc|
    if quantity < item_quantity
      q = if loc['quantity'] >= (item_quantity - quantity)
            item_quantity - quantity
          else
            loc['quantity'].to_i
          end
      if q > 0
        quantity += q
        ProductWarehouseLoc.create(salesman_travel_id: salesman_travel_id,
                                   product_id: product_id,
                                   location_id: loc.id,
                                   feature_item_id: feature_item_id,
                                   quantity: q,
                                   load_at: load_at,
                                   salesman_at: salesman_at,
                                   add_stock: add_stock)
        is_added = true
      end
    else
      break
    end
  }
  # TODO үүний утаснаас байршуулдаг болсон үед авч хаях
  unless is_added
    ProductWarehouseLoc.create(salesman_travel_id: salesman_travel_id,
                               product_id: product_id,
                               location_id: 1,
                               feature_item_id: feature_item_id,
                               quantity: item_quantity)

  end
  is_added
end