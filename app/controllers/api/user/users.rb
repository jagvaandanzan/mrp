module API
  module USER
    class Users < Grape::API
      resource :users do

        get do
          present :user, current_user, with: API::USER::Entities::User
        end
        resource :device do
          desc "PATCH users/device"
          params do
            requires :device_token, type: String
          end
          patch do
            user = current_user
            user.update_attribute(:device_token, params[:device_token])

            present :updated_at, user.updated_at
          end
        end

        resource :notifications do
          desc "GET users/notifications"
          get do
            notifications = Notification.by_user(current_user.id).page(1)
            present :notifications, notifications, with: API::USER::Entities::Notification
          end
        end

        resource :notification do
          desc "POST users/notification"
          params do
            requires :title, type: String
            requires :content, type: String
            optional :token, type: String
          end
          patch do
            user = current_user
            if params[:token].present?
              user.device_token = params[:token]
            end
            ApplicationController.helpers.send_notification(user,
                                                            user.push_options('user', params[:title], params[:content]))
            present :updated_at, Time.now
          end
        end

        resource :change do
          resource :pin do
            desc "PATCH users/change/pin"
            params do
              requires :pin_code, type: String
            end
            patch do
              user = current_user
              user.pin_code = params[:pin_code]

              if user.save
                present :updated_at, user.updated_at
              else
                error!(user.errors.full_messages, 422)
              end
            end
          end
        end

      end
    end
  end
end