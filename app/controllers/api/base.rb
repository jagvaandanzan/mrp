module API
  class Base < Grape::API
    mount API::V1::Base
    mount API::SALESMAN::Base
    mount API::USER::Base
  end
end
