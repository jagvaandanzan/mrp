module API
  module SALESMAN
    class Base < Grape::API
      version 'salesman', using: :path
      format :json
      formatter :json, Grape::Formatter::Jbuilder

      # 例外ハンドル
      rescue_from ActiveRecord::RecordNotFound do |e|
        error!("Couldn't find data", 404)
      end

      rescue_from ActiveRecord::RecordNotUnique do |e|
        error!(e.message, 422)
      end

      rescue_from ActiveRecord::RecordInvalid do |e|
        error!(e.message, 422)
      end

      helpers do
        def authenticate_error!
          h = {'Access-Control-Allow-Origin' => "*",
               'Access-Control-Request-Method' => %w{GET POST OPTIONS}.join(",")}
          error!('You need to log in to use the app.', 401, h)
        end

        def current_salesman
          @resource
        end

        # header から認証に必要な情報を取得
        def authenticate_user!
          return if @resource
          uid = request.headers['Uid']
          token = request.headers['Access-Token']
          client = request.headers['Client']
          user = Salesman.find_by(uid: uid)
          if user && user.valid_token?(token, client)
            @resource = user
          else
            @resource = nil
            authenticate_error!
          end
        end
      end

      before do
        authenticate_user!
      end

      # mounts
      mount API::SALESMAN::Distributing
      mount API::SALESMAN::Travels
    end
  end
end
# uid: ch.enkhamgalan@yahoo.com
# access-token: ohJhZNxmipJM8DRcYc67Kw
# client: 9PkhsJ9nNjx9gYtXAtT0WA
# Content-Type: application/json; charset=utf-8
# expiry: 1576568760