module API
  module SALESMAN
    class Passwords < Grape::API
      resource :passwords do
        resource :reset do
          desc "POST passwords/reset"
          params do
            requires :phone, type: Integer
          end
          post do
            salesman = Salesman.find_by_uid(params[:phone])
            if salesman.present?
              c = ""
              (1..6).each do |n|
                c += rand(10).to_s
              end
              ApplicationController.helpers.send_sms(salesman.phone, "Market.mn, code: #{c}")
              salesman.update_column(:reset_code, c)
              present :message, 'Нууц код илгээлээ'
            else
              error!('Утасны дугаар олдсонгүй!', 422)
            end
          end
        end

        resource :change do
          desc "POST passwords/change"
          params do
            requires :phone, type: Integer
            requires :reset_code, type: String
            requires :password, type: String
            requires :password_confirmation, type: String
          end
          post do
            salesman = Salesman.find_by_phone(params[:phone])
            if salesman.present?
              if salesman.reset_code == params[:reset_code]
                url_token, hashed_token = Devise.token_generator.generate(Salesman, :reset_password_token)
                salesman.update_columns(reset_password_token: hashed_token,
                                    reset_password_sent_at: Time.now.utc)

                salesman.password = params[:password]
                salesman.password_confirmation = params[:password_confirmation]
                salesman.change_pass = true
                if salesman.valid?
                  salesman.update_column(:reset_code, nil)
                  Salesman.reset_password_by_token({reset_password_token: url_token,
                                                password: params[:password],
                                                password_confirmation: params[:password_confirmation]})
                  present :message, I18n.t('devise.passwords.updated')
                else
                  error!(salesman.errors.full_messages, 422)
                end
              else
                error!('Код буруу байна!', 422)
              end
            else
              error!('Утасны дугаар олдсонгүй!', 422)
            end
          end
        end
      end

    end
  end
end