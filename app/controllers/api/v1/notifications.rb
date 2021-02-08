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
      end
    end
  end
end