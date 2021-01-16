module API
  module SALESMAN
    class Salesmen < Grape::API
      resource :salesmen do

        get do
          present :salesmen, current_salesman, with: API::SALESMAN::Entities::Salesman
        end

        resource :device do
          desc "PATCH salesmen/device"
          params do
            requires :device_token, type: String
          end
          patch do
            salesman = current_salesman
            salesman.update_attribute(:device_token, params[:device_token])

            present :updated_at, salesman.updated_at
          end
        end

        resource :notifications do
          desc "GET salesmen/notifications"
          get do
            notifications = Notification.by_salesman(current_salesman.id).page(1)
            present :notifications, notifications, with: API::SALESMAN::Entities::Notification
          end
        end

        resource :notification do
          desc "POST salesmen/notification"
          params do
            requires :title, type: String
            requires :content, type: String
            optional :token, type: String
          end
          patch do
            salesman = current_salesman
            if params[:token].present?
              salesman.device_token = params[:token]
            end
            ApplicationController.helpers.send_noti_salesman(salesman,
                                                             salesman.push_options('salesman', params[:title], params[:content]))
            present :updated_at, Time.now
          end
        end

        resource :track do
          desc "GET salesmen/track"
          params do
            requires :latitude, type: Float
            requires :longitude, type: Float
          end
          post do
            SalesmanTrack.create(
                salesman: current_salesman,
                latitude: params[:latitude],
                longitude: params[:longitude]
            )
            present :updated_at, Time.now
          end
        end

      end
    end
  end
end