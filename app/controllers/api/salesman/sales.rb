module API
  module SALESMAN
    class Sales < Grape::API
      resource :sales do

        resource :sale_items do
          desc "GET sales/sale_items"
          get do
            status_id = ProductSaleStatus.find_by_alias("oper_confirmed")
            item_hash = ProductFeatureItem.available_sale_item_hash(current_salesman.id, status_id)
            features = []
            item_hash.each {|h|
              feature_item = ProductFeatureItem.find(h['feature_item_id'])
              features << {id: feature_item.id, image: feature_item.img, name: feature_item.product_name, feature: feature_item.name, barcode: feature_item.barcode, quantity: h['quantity']}
            }
            features
          end
        end

        resource :sale_returns do
          desc "GET sales/sale_returns"
          get do
            sale_returns = ProductSaleReturn.sale_available(current_salesman.id)
                               .status_not_confirmed
            present :sale_returns, sale_returns, with: API::SALESMAN::Entities::ProductSaleReturnReturn
          end
        end

        resource :signature do
          desc "POST sales/signature"
          params do
            requires :image, type: File
            requires :returns, type: Array[JSON]
          end
          post do

            # sale_items = ProductSaleItem.sale_available(current_salesman.id)
            #                  .status_not_confirmed
            image = params[:image] || {}
            return_sign = SalesmanReturnSign
                              .by_salesman(current_salesman.id)
                              .by_user(nil)
                              .first
            if return_sign.present?
              return_sign.given = image[:tempfile]
              return_sign.given_file_name = image[:filename]
              return_sign.save
              present :sign_at, return_sign.updated_at
            else
              salesman_returns = SalesmanReturn.by_sign_user(nil)
                                     .by_salesman(current_salesman.id)

              if salesman_returns.count == 0
                error!(I18n.t('errors.messages.not_available_product'), 422)
              else
                return_sign = SalesmanReturnSign.create(salesman: current_salesman,
                                                        return_count: salesman_returns.count,
                                                        given: image[:tempfile],
                                                        given_file_name: image[:filename])
                salesman_returns.each {|ret|
                  ret.update_column(:sign_id, return_sign.id)
                }
                present :sign_at, return_sign.created_at
              end
            end

          end
        end

        resource :to_return do
          desc "POST sales/to_return"
          params do
            optional :sale_item_id, type: Integer
            optional :sale_return_id, type: Integer
            requires :quantity, type: Integer
          end
          post do
            if params[:sale_item_id].present?
              sale_item = ProductSaleItem.find(params[:sale_item_id])
              available_quantity = ProductFeatureItem.sale_available_item_quantity(current_salesman.id, sale_item.feature_item_id)
              if available_quantity >= params[:quantity]
                salesman_return = SalesmanReturn.by_sale_item_salesman(sale_item.id, current_salesman.id).first
                if salesman_return.present?
                  salesman_return.update_column(:quantity, params[:quantity])
                else
                  salesman_return = SalesmanReturn.create(salesman: current_salesman,
                                                          product: sale_item.product,
                                                          feature_item: sale_item.feature_item,
                                                          sale_item: sale_item,
                                                          quantity: params[:quantity])
                end

                present :salesman_return, salesman_return, with: API::SALESMAN::Entities::SalesmanReturn
              else
                error!(I18n.t('errors.messages.available_quantity'), 422)
              end
            elsif params[:sale_return_id].present?
              sale_return = ProductSaleReturn.find(params[:sale_return_id])
              product_sale_item = sale_return.product_sale_item
              available_quantity = ProductSaleReturn.by_available_feature_id(current_salesman.id, product_sale_item.feature_item_id)
              if available_quantity >= params[:quantity]
                salesman_return = SalesmanReturn.by_sale_return_salesman(sale_return.id, current_salesman.id).first
                if salesman_return.present?
                  salesman_return.update_column(:quantity, params[:quantity])
                else
                  salesman_return = SalesmanReturn.create(salesman: current_salesman,
                                                          product: product_sale_item.product,
                                                          feature_item: product_sale_item.feature_item,
                                                          sale_return: sale_return,
                                                          quantity: params[:quantity])
                end

                present :salesman_return, salesman_return, with: API::SALESMAN::Entities::SalesmanReturn
              else
                error!(I18n.t('errors.messages.available_quantity'), 422)
              end
            else
              error!(I18n.t('errors.messages.available_quantity'), 422)
            end

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