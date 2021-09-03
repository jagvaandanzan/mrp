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

        resource :password do
          desc "POST salesmen/password"
          params do
            requires :pin_code, type: String
            requires :password, type: String
            requires :password_confirmation, type: String
          end
          post do
            salesman = current_salesman
            if params[:pin_code] == salesman.pin_code
              salesman.password = params[:password]
              salesman.password_confirmation = params[:password_confirmation]
              salesman.change_pass = true
              if salesman.valid?
                if salesman.save
                  present :salesman, salesman, with: API::SALESMAN::Entities::Salesman
                else
                  error!(salesman.errors.full_messages, 422)
                end
              else
                error!(salesman.errors.full_messages, 422)
              end
            else
              error!("Пин код буруу байна!", 422)
            end
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
          desc "POST salesmen/track"
          params do
            requires :latitude, type: Float
            requires :longitude, type: Float
          end
          post do
            salesman_track = SalesmanTrack.create(
                salesman: current_salesman,
                latitude: params[:latitude],
                longitude: params[:longitude]
            )
            SalesmanTrackJob.perform_later(salesman_track.id)
            present :updated_at, Time.now
          end
        end

      end
    end
  end
end