module API
  module SALESMAN
    class Sales < Grape::API
      resource :sales do

        resource :sale_returns do
          desc "POST sales/sale_returns"
          params do
            requires :sale_item, type: Boolean
          end
          post do
            status_id = ProductSaleStatus.find_by_alias("oper_confirmed")
            item_hash = if params[:sale_item]
                          ProductFeatureItem.available_sale_item_hash(current_salesman.id, status_id)
                        else
                          ProductFeatureItem.available_sale_return_hash(current_salesman.id, status_id)
                        end
            features = []
            item_hash.each {|h|
              feature_item = ProductFeatureItem.find(h['feature_item_id'])
              features << {id: feature_item.id, image: feature_item.img, name: feature_item.product_name, feature: feature_item.name, barcode: feature_item.barcode, quantity: h['quantity']}
            }
            features
          end
        end

        resource :signature do
          desc "POST sales/signature"
          params do
            requires :sale_item, type: Boolean
            requires :image, type: File
            requires :returns, type: Array[JSON]
          end
          post do
            image = params[:image] || {}
            return_sign = SalesmanReturnSign.new(salesman: current_salesman,
                                                 given: image[:tempfile],
                                                 given_file_name: image[:filename],
                                                 is_item: true)
            if params[:sale_item]
              sale_items = ProductSaleItem.sale_available(current_salesman.id)
                               .status_not_confirmed
              params['feature_items'].each {|feature|
                sale_items.by_feature_item_id(feature['id']).each {|sale_item|
                  return_sign.salesman_returns << SalesmanReturn.new(salesman: current_salesman,
                                                                     product: sale_item.product,
                                                                     feature_item: sale_item.feature_item,
                                                                     sale_return: sale_return,
                                                                     quantity: sale_item.quantity)
                }
              }
            else
              sale_returns = ProductSaleReturn.sale_available(current_salesman.id)
                                 .status_not_confirmed
              params['feature_items'].each {|feature|
                sale_returns.by_feature_item_id(feature['id']).each {|sale_return|
                  feature_item = sale_return.feature_item
                  return_sign.salesman_returns << SalesmanReturn.new(salesman: current_salesman,
                                                                     product_id: feature_item.product_id,
                                                                     feature_item: feature_item,
                                                                     sale_return: sale_return,
                                                                     quantity: sale_return.quantity)
                }
              }
            end
            return_sign.save

            present :sign_at, return_sign.created_at

          end
        end

        resource :return_requests do
          desc "GET sales/return_requests"
          get do
            return_signs = SalesmanReturnSign.by_salesman(current_salesman.id)
                               .by_user(nil)
            present :return_requests, return_signs, with: API::SALESMAN::Entities::SalesmanReturnSign
          end

          route_param :id do
            resource :products do
              desc "GET sales/return_requests/:id/products"
              get do
                return_sign = SalesmanReturnSign.find(params[:id])

                present :products, return_sign.salesman_returns, with: API::SALESMAN::Entities::SalesmanReturn
              end
            end
          end
        end


        resource :products do
          resource :available do
            desc "GET sales/products/available"
            get do
              products = Product.sale_available(current_salesman.id)
              present :products, products, with: API::SALESMAN::Entities::ProductSearch
            end
          end

          route_param :id do
            resource :items do
              desc "GET sales/products/:id/items"
              get do
                product_feature_items = ProductFeatureItem.available_product(current_salesman.id, params[:id])
                present :feature_items, product_feature_items, with: API::SALESMAN::Entities::ProductFeatureItems
              end
              route_param :f_item_id do
                resource :quantity do
                  desc "GET sales/products/:id/items/:f_item_id/quantity"
                  get do
                    feature_item = ProductFeatureItem.find(params[:f_item_id])
                    quantity = ProductFeatureItem.sale_available_item_quantity(current_salesman.id, params[:f_item_id])
                    present :available_quantity, quantity
                    present :price, feature_item.price
                  end
                end
              end
            end
          end
        end

        resource :sell do
          desc "POST sales/sell"
          params do
            requires :feature_item_id, type: Integer
            requires :phone, type: Integer
            requires :quantity, type: Integer
          end
          post do
            salesman = current_salesman
            quantity = ProductFeatureItem.sale_available_item_quantity(salesman.id, params[:feature_item_id])
            feature_item = ProductFeatureItem.find(params[:feature_item_id])
            product_sale_items = ProductSaleItem.find_by_salesman_id(feature_item.id, salesman.id)

            if feature_item.present? && product_sale_items.present?
              product_sale_item = product_sale_items.first

              sale_direct = ProductSaleDirect.new(remainder: quantity,
                                                  salesman: salesman,
                                                  phone: params[:phone],
                                                  price: feature_item.price,
                                                  product: feature_item.product,
                                                  feature_item: feature_item,
                                                  sale_item: product_sale_item,
                                                  quantity: params[:quantity])
              if sale_direct.save
                present :created_at, sale_direct.created_at
              else
                error!(sale_direct.errors.full_messages, 422)
              end
            end
          end
        end

        resource :transfer do
          resource :history do
            desc "POST sales/transfer/history"
            params do
              requires :date, type: DateTime
            end
            post do
              warehouse_locs = ProductWarehouseLoc.salesman_with_date(current_salesman.id, ApplicationController.helpers.local_date(params[:date]))
              present :products, warehouse_locs, with: API::USER::Entities::ProductWarehouseUserSign
            end
          end

          resource :return do
            desc "POST sales/transfer/return"
            params do
              requires :date, type: DateTime
            end
            post do
              salesman_returns = SalesmanReturn.salesman_with_date(current_salesman.id, ApplicationController.helpers.local_date(params[:date]))
              present :products, salesman_returns, with: API::USER::Entities::SalesmanReturnUserSign
            end
          end
        end

      end
    end
  end
end