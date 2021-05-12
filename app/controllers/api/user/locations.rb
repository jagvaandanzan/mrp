module API
  module USER
    class Locations < Grape::API
      resource :locations do
        resource :desk do
          desc "POST locations/desk"
          params do
            requires :x, type: Integer
            requires :y, type: Integer
            requires :z, type: Integer
            optional :get_products
          end
          post do
            locations = ProductLocation.by_xyz(params[:x], params[:y], params[:z])
            location = if locations.present?
                         locations.first
                       else
                         ProductLocation.create(x: params[:x], y: params[:y], z: params[:z])
                       end
            present :location_id, location.id
            if params[:get_products].present?
              present :products, ProductLocationBalance.by_location_id(location.id).sum_quantity
            end
          end

          route_param :id do
            resource :product do
              resource :scan do
                desc "POST locations/desk/{id}/product/scan"
                params do
                  requires :barcode, type: String
                end
                post do
                  feature_item = ProductFeatureItem.find_by_barcode(params[:barcode])
                  if feature_item.present?
                    quantity = feature_item
                                   .product_location_balances
                                   .by_location_id(params[:id])
                                   .sum(:quantity)
                    feature_item.quantity = quantity
                    present :feature_item, feature_item, with: API::USER::Entities::ProductFeatureItem
                  else
                    error!(I18n.t("errors.messages.not_found"), 422)
                  end
                end
              end

              resource :finish do
                desc "POST locations/desk/{id}/product/finish"
                params do
                  requires :feature_items, type: Array[JSON]
                end
                post do
                  loc_transfer = ProductLocationTransfer.new(user: current_user,
                                                             product_location_id: params[:id])
                  params['feature_items'].each {|item|
                    loc_transfer.product_location_trans_items << ProductLocationTransItem.new(
                        location_transfer: loc_transfer,
                        product_id: item['product_id'],
                        product_feature_item_id: item['id'],
                        quantity: item['quantity'])
                  }

                  if loc_transfer.save
                    present :location_transfer, loc_transfer, with: API::USER::Entities::LocationTransfer
                  else
                    error!(loc_transfer.errors.full_messages, 422)
                  end
                end
              end
            end
          end
        end

        resource :transfer do
          route_param :id do
            desc "GET transfer/{id}"
            get do
              loc_transfer = ProductLocationTransfer.find(params[:id])
              present :location_transfer, loc_transfer, with: API::USER::Entities::LocationTransfer
            end
          end
        end

        resource :to_transfer do
          desc "POST locations/to_transfer"
          params do
            requires :x, type: Integer
            requires :y, type: Integer
            requires :z, type: Integer
            requires :transfer_id, type: Integer
            requires :trans_item_id, type: Integer
            requires :feature_item_id, type: Integer
            requires :quantity, type: Integer
          end
          post do
            transfer = ProductLocationTransTo.new(
                x: params[:x], y: params[:y], z: params[:z],
                location_transfer_id: params[:transfer_id],
                trans_item_id: params[:trans_item_id],
                product_location_id: params[:location_id],
                product_feature_item_id: params[:feature_item_id],
                quantity: params[:quantity]
            )
            if transfer.save
              present :success, true
            else
              error!(transfer.errors.full_messages, 422)
            end
          end
        end

        resource :transfers do
          desc "POST locations/transfers"
          params do
            requires :date, type: DateTime
            optional :open, type: Boolean
          end
          post do
            transfers = ProductLocationTransfer
                            .by_user_id(current_user.id)
                            .by_date(ApplicationController.helpers.local_date(params[:date]))
                            .by_open(params[:open])

            present :transfers, transfers, with: API::USER::Entities::LocationTransferList
          end
        end

      end
    end
  end
end