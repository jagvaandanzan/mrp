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

              # Өөрийн бичсэн үзэгдэлүүдийг алгасах
              if from_id != '0'
                if obj[:item] == "comment"
                  Rails.logger.info(entry)
                  Rails.logger.info(obj[:message])
                  Rails.logger.info("post_id=" + obj[:post_id])
                  Rails.logger.info("comment_id=" + obj[:comment_id])
                  if obj[:parent_id].present?
                    Rails.logger.info("parent_id=" + obj[:parent_id])
                  end
                end
              end

            }
            # Time.at(i)
            # change
          }

          status 200
        end
      end
    end
  end
end