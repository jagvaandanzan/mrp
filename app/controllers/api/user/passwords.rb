module API
  module USER
    class Passwords < Grape::API
      resource :passwords do
        resource :reset do
          desc "POST passwords/reset"
          params do
            requires :email, type: String
          end
          post do
            user = User.find_by_email(params[:email])
            if user.present?
              url_token, hashed_token = Devise.token_generator.generate(User, :reset_password_token)
              # Rails.logger.debug("url_token = " + url_token.to_s)
              user.reset_password_app(user.email, url_token)
              User.transaction do
                user.reset_password_token = hashed_token
                user.reset_password_sent_at = Time.now
                user.save(validate: false)
              end

              {message: I18n.t("devise.passwords.send_instructions")}
            else
              error!(I18n.t('devise.passwords.no_email'), 422)
            end
          end
        end
        # tokilog://?reset_password_token=DJZsr-tFz1gAgW3sCQMZ
        resource :change do
          desc "POST passwords/change"
          params do
            requires :reset_password_token, type: String
            requires :password, type: String
            requires :password_confirmation, type: String
          end
          post do

            # Rails.logger.debug("token = " + params.to_s)
            user = User.with_reset_password_token(params[:reset_password_token])
            if user.present?
              user.password = params[:password]
              user.password_confirmation = params[:password_confirmation]
              if user.valid?
                if user.reset_password_period_valid?
                  User.reset_password_by_token(params)
                  {email: user.email, message: I18n.t('devise.passwords.updated')}
                else
                  error!(I18n.t("errors.messages.expired"), 422)
                end
              else
                msg = ""
                user.errors.full_messages.each_with_index {|err, index|
                  if index > 0
                    msg += "\n "
                  end
                  msg += err
                }
                error!(msg.to_s, 422)
              end
            else
              error!(I18n.t('devise.passwords.no_token'), 422)
            end
          end
        end
      end

    end
  end
end