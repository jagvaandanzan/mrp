module API
  module USER
    class Sales < Grape::API
      resource :sales do
        resource :salesmen do
          desc "GET sales/salesmen"
          get do
            salesmen = Salesman.all
            present :salesmen, salesmen, with: API::USER::Entities::Salesman
          end

          route_param :id do
            resource :sale_items do
              desc "GET sales/salesmen/:id/sale_items"
              get do
                sale_items = ProductSaleItem.sale_available(params[:id])
                present :sale_items, sale_items, with: API::SALESMAN::Entities::ProductSaleItem
              end
            end
          end
        end

        resource :return_requests do
          desc "GET sales/return_requests"
          get do
            return_signs = SalesmanReturnSign.by_user(nil)
            present :return_requests, return_signs, with: API::USER::Entities::SalesmanReturnSign
          end

          route_param :id do
            resource :products do
              desc "GET sales/return_requests/:id/products"
              get do
                return_sign = SalesmanReturnSign.find(params[:id])

                present :products, return_sign.salesman_returns, with: API::SALESMAN::Entities::SalesmanReturn
              end
            end

            resource :signature do
              desc "POST sales/return_requests/:id/signature"
              params do
                requires :image, type: File
              end
              post do

                return_sign = SalesmanReturnSign.find(params[:id])
                if return_sign.received.present?
                  present :sign_at, return_sign.updated_at
                else
                  image = params[:image] || {}

                  salesman_returns = return_sign.salesman_returns
                                         .by_user(current_user)
                  if return_sign.salesman_returns.count != salesman_returns.count
                    error!(I18n.t('errors.messages.please_check_all'), 422)
                  else
                    return_sign.received = image[:tempfile]
                    return_sign.received_file_name = image[:filename]
                    return_sign.user = current_user
                    return_sign.save

                    salesman_returns.each {|ret|
                      sales_item = ret.sale_item
                      sales_item.update_column(:back_quantity, sales_item.back_quantity.present? ? sales_item.back_quantity + ret.quantity : ret.quantity)
                      ProductBalance.create(product: ret.product,
                                            feature_item: ret.feature_item,
                                            salesman_return: ret,
                                            user: current_user,
                                            quantity: ret.quantity)
                      ProductLocationBalance.create(x: 1, y: 1, z: 2,
                                                    product_feature_item: ret.feature_item,
                                                    salesman_return: ret,
                                                    quantity: quantity)
                    }
                    return_sign.send_notification_to_salesman
                    present :sign_at, return_sign.updated_at
                  end
                end
              end
            end
          end

          resource :return_product do
            desc "PATCH sales/return_requests/return_product"
            params do
              requires :product_id, type: Integer
              requires :barcode, type: Boolean
            end
            patch do
              salesman_return = SalesmanReturn.find(params[:product_id])
              salesman_return.user = current_user
              salesman_return.barcode = params[:barcode]
              salesman_return.save
              present :returned, salesman_return.updated_at
            end
          end
        end

        resource :item do
          route_param :sale_item_id do
            resource :scan do
              desc "POST sales/item/:sale_item_id/scan"
              params do
                optional :barcode, type: String
                optional :skip_barcode, type: Boolean
              end
              post do
                # Rails.logger.info("id ===  + #{params[:sale_item_id]} #{params[:barcode]}")
                is_success = false
                sales_item = ProductSaleItem.find(params[:sale_item_id])
                if params[:skip_barcode].present? && params[:skip_barcode]
                  is_success = true
                elsif params[:barcode].present?
                  if sales_item.feature_item.barcode == params[:barcode]
                    is_success = true
                  else
                    error!("Couldn't find by barcode", 422)
                  end
                end

                if is_success
                  present :sales_item, sales_item, with: API::SALESMAN::Entities::ProductSaleItem
                else
                  error!("Couldn't find data", 422)
                end
              end
            end
          end
        end
      end
    end
  end
end