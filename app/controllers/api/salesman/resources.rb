module API
  module SALESMAN
    class Resources < Grape::API
      resource :change do
        resource :pin do
          desc "PATCH change/pin"
          params do
            requires :pin_code, type: String
          end
          patch do
            salesman = current_salesman
            salesman.pin_code = params[:pin_code]

            if salesman.save
              present :updated_at, salesman.updated_at
            else
              error!(salesman.errors.full_messages, 422)
            end
          end
        end
      end
    end
  end
end