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

            present params['hub.challenge']

          end
        end

        post do
          # params do
          #   requires :entry, type: JSON
          #   requires :object, type: String
          # end

          json = env['api.request.body'].to_json
          Rails.logger.info(json)

          present :updated, Time.now
        end

      end
    end
  end
end