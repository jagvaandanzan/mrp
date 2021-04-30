module API
  module V1
    class Notifications < Grape::API
      resource :notifications do
        desc "POST notifications"
        get do
          if params['hub.mode'].present? && params['hub.challenge'].present? &&
              params['hub.verify_token'].present? && params['hub.verify_token'] == "ea_market_mrp_secret"

            Rails.logger.debug("mode:" + params['hub.mode'].to_s)
            Rails.logger.debug("challenge:" + params['hub.challenge'].to_s)
            Rails.logger.debug("verify_token:" + params['hub.verify_token'].to_s)

            present params['hub.challenge'].to_i

          end
        end

        post do
          params do
            requires :entry, type: Array[JSON]
            requires :object, type: String
          end
          # json = env['api.request.body'].to_json
          # object = params[:object]
          entries = params[:entry]

          entries.each {|entry|
            entry[:changes].each {|change|
              obj = change[:value]
              from_id = obj[:from][:id]

              # Rails.logger.info(entry.to_json)
              # Өөрийн бичсэн үзэгдэлүүдийг алгасах
              if from_id != '0'
                if obj[:item] == "comment"
                  # Rails.logger.info(entry.to_json)
                  FbNotificationsJob.perform_later(obj, from_id)
                elsif obj[:item] == "reaction"
                  # Rails.logger.info(entry.to_json)
                  reaction_type = obj[:reaction_type]
                  if reaction_type == "like" || reaction_type == "love" || reaction_type == "wow" ||
                      reaction_type == "care" || reaction_type == "support"
                    FbCommentReaction.create(post_id: obj[:post_id].split('_')[1],
                                             user_id: from_id,
                                             reaction: reaction_type)
                  end
                end
              end
            }
          }

          status 200
        end

        resource :bank do
          desc "POST notifications/bank"
          params do
            requires :ids, type: Array[Integer]
          end
          post do
            params[:ids].each {|id|
              BankTransactionJob.perform_later BankTransaction.find(id)
            }
          end
        end

        resource :tax do
          desc "POST notifications/tax"
          post do

            present :code, 'SY 70097980'
            present :number, "000005036895106210115000002412825"
            present :qr, '1430664350533053750475141026405108271689485368031610319801940237779770696663503181500249213931200741155140568804509581335789494940493038736835683284108142827879328166754490249488907717634489528234186972418490800353994184260206674997167819014082666894280317034698496925984658198527953347290113422948302779356839239640'
          end
        end

        resource :socialpay do
          desc "POST notifications/socialpay"
          params do
            requires :amount, type: String
            requires :bank, type: String
            requires :errorDesc, type: String
            requires :checksum, type: String
            requires :errorCode, type: String
            requires :cardHolder, type: String
            optional :transactionId, type: String
            requires :cardNumber, type: String
            optional :token, type: String
          end
          post do
            Rails.logger.info("#{socialpay} == #{params}")
            if params[:errorCode] == "000"
              psw = ProductSaleWeb.instance
              psw.create(params[:transactionId], params[:amount])
            end
          end
        end

        resource :itoms do
          desc "POST notifications/itoms"
          params do
            requires :barcode, type: Integer
          end
          post do
            item = ProductFeatureItem.find_by_barcode(params[:barcode])
            if item.present?
              present :link, "#{ENV['WEB_DOMAIN']}products/#{item.product_id}"
              present :image, item.img.present? ? "#{ENV['DOMAIN_NAME']}#{item.img.url(:tumb)}" : "#{ENV['WEB_DOMAIN']}images/no_image.png"
            else
              error!("Not found in barcode", 500)
            end
          end
        end

        resource :balance do
          desc "POST notifications/balance"
          params do
            requires :barcode, type: String
            requires :price, type: String
            requires :name, type: String
            requires :company_id, type: String
            requires :c2_qty, type: Integer
            requires :item_serials, type: Array[JSON]
          end
          post do
            items = []
            product_id = nil
            # Rails.logger.info("itoms_balance")
            params['item_serials'].each {|ser|
              item = ProductFeatureItem.find_by_barcode(ser['serial_barcode'])
              if item.present?
                product_id = item.product_id if product_id.nil?
                items << {id: item.id, balance: ser['c2_qty']}
              end
              # Rails.logger.info("#{ser['serial_barcode']} == #{ser['c2_qty']}")
            }

            param = {product_id: product_id, balance: params['c2_qty'], items: items}.to_json
            # Rails.logger.debug("itoms_balance_send=#{param}")
            ApplicationController.helpers.api_request("product/balances", 'patch', param)
            {send: true}
          end
        end

      end
    end
  end
end