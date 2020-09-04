module API
  module USER
    class Sales < Grape::API
      resource :sales do

        resource :notification do
          desc "POST sales/notification"
          params do
            requires :title, type: String
            requires :content, type: String
          end
          patch do
            user = current_user
            ApplicationController.helpers.send_notification(user,
                                                            user.push_options('user', params[:title], params[:content]))
            present :updated_at, Time.now
          end
        end

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

            resource :load do
              desc "PATCH sales/item/:sale_item_id/load"
              params do
                requires :quantity, type: Integer
              end
              patch do
                message = ""
                r_s = 200
                Rails.logger.info("id =  #{params[:sale_item_id]}  qnty =   #{params[:quantity]}")
                sales_item = ProductSaleItem.find(params[:sale_item_id])

                sales_item.update_column(:back_quantity, sales_item.back_quantity.present? ? sales_item.back_quantity + params[:quantity] : params[:quantity])
                product_balance = sales_item.product_balance
                product_balance.update_column(:quantity, product_balance.quantity + params[:quantity])
                present :load_at, sales_item.updated_at
                message = I18n.t('alert.removed_successfully')

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